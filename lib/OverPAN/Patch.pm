package OverPAN::Patch;

use OverPAN;    # make sure INC is set for vendor
use OverPAN::std;
use OverPAN::Logger;

use Simple::Accessor qw{
  cli
  http
  git

  distro_name
  distro_version
  distro_url

  distro_buildname

  tarball

  work_dir
  call_from
};
with 'OverPAN::Roles::JSON';

use OverPAN::Unpacker ();
use OverPAN::Http     ();
use OverPAN::Git      ();

use File::Slurper ();
use File::Copy qw{move copy};
use File::Path qw(mkpath rmtree);
use CPAN::DistnameInfo ();
use MetaCPAN::Client   ();

use constant OVERPAN_JSON => '.overpan.json';

sub build ( $self, %options ) {

    #FATAL("OverPAN::Patch needs a cli") unless $options{cli};

    return $self;
}

sub _build_work_dir($self) {
    my $path = $self->cache_dir . '/' . $self->distro_buildname;

    DEBUG("Patch directory: $path");

    # do not create/remove the directory as part of the builder

    return $path;
}

sub _build_distro_buildname($self) {
    my $distro = $self->distro_name . '-' . $self->distro_version;
    $distro =~ s{\.+}{_}g;

    my $c = 0;
    while ( $distro =~ s{[^A-Za-z0-9_-]}{}g ) {
        ++$c;
        FATAL( "Cannot cleanup distro directory: " . $self->distro_name )
          if $c > 10;
    }

    return $distro;
}

sub _build_http {
    return OverPAN::Http->new;    # maybe move it to the client?
}

sub _build_git($self) {
    return OverPAN::Git->new( $self->work_dir );  # maybe move it to the client?
}

sub setup ( $self, $distro ) {                    # MAYBE move in build...
                                                  # create build directory
                                                  # download and extract tarball
                                                  # git init directory
                                                  # apply patches

    # 1. name, version, url for the distro
    return unless $self->set_name_version_url_for_distro($distro);

    DEBUG( "Distribution name   : " . $self->distro_name );
    DEBUG( "Distribution version: " . $self->distro_version );
    DEBUG( "Distribution URL    : " . $self->distro_url );

    FATAL("OverPAN::Patch needs a cli") unless $self->cli;

    # force option cleanup previous patches
    my $need_setup = 1;
    my $work_dir   = $self->work_dir;
    if ( -d $work_dir && -d "$work_dir/.git" ) {
        my $dv = $self->distro_with_version;
        if ( $self->cli->force ) {
            INFO("Removing previous session for $dv [--force]");
            rmtree($work_dir);
        }
        else {
            $need_setup = 0;
            INFO( <<"EOS");
Reusing a previous patch session for $dv
If you want to start a new session 
either cancel the existing one using
    overpan abort
or start a fresh session by using '--force'
    overpan patch --force $dv
EOS
        }
    }

    DEBUG("need_setup ? $need_setup");

    if ($need_setup) {

        # download (if needed) and extract tarball
        $self->download_tarball or return;
        $self->extract_tarball  or return;

        # git init directory + pa
        $self->git_init;
    }

    return 1;
}

sub commit($self) {
    $self->setup_for_commit_abort;
}

sub abort($self) {
    my $data = $self->setup_for_commit_abort
      or do {
        FAIL "Current directory does not appear to be a valid OverPAN path:\n"
          . Cwd::cwd;
        return;
      };

    chdir( $self->call_from ) or do {
        FAIL( "Cannot chdir to " . $self->call_from );
        return;
    };

    if ( my $wd = $self->work_dir ) {
        if ( -d "$wd/.git" ) {
            INFO("Removing directory $wd");
            rmtree($wd);
        }
    }

    OK( "Patch aborted for " . $self->distro_buildname );

    return;
}

sub _build_tarball($self) {
    return $self->cache_dir . '/' . $self->distro_buildname . '.tar.gz';
}

sub git_init($self) {
    my $git = $self->git;
    $git->init;

    $self->setup_overspan_json;

    # apply patches
    $self->apply_patches;

    return;
}

sub setup_for_commit_abort($self) {
    return unless -f OVERPAN_JSON;
    my $data;
    eval {
        $data = $self->json->decode( File::Slurper::read_text(OVERPAN_JSON) );
        1;
    } or do {
        FAIL( "Cannot read " . OVERPAN_JSON() . " file from " . Cwd::cwd() );
        DEBUG($@) if $@;
        return;
    };

    return unless defined $data->{overpan_version};
    return unless defined $data->{call_from};

    $self->work_dir( Cwd::cwd() );

    $self->call_from( $data->{call_from} );

    # restore some variables
    $self->distro_name( $data->{distro_name} );
    $self->distro_version( $data->{distro_version} );
    $self->distro_url( $data->{distro_url} );
    $self->distro_buildname( $data->{distro_buildname} );

    return $data;
}

sub setup_overspan_json($self) {

    my $data = {
        overpan_version  => $OverPAN::VERSION,
        call_from        => $self->cli->cwd,
        distro_name      => $self->distro_name,
        distro_version   => $self->distro_version,
        distro_url       => $self->distro_url,
        distro_buildname => $self->distro_buildname,
    };

    my $str = $self->json->encode($data);
    File::Slurper::write_text( $self->work_dir . '/' . OVERPAN_JSON, $str );

    return 1;

    # $self->json->decode( read_file( $self->file ) );
}

sub apply_patches($self) {
    DEBUG("git_apply_patches: ");

    my $git = $self->git;

    my @patches;    # FIXME
    foreach my $p (@patches) {
        $git->apply_patch($p);
    }

    return;
}

sub download_tarball($self) {
    FATAL("No tarball URL set to download") unless defined $self->distro_url;

    my $tarball_url      = $self->distro_url;
    my $tarball_location = $self->tarball;

    # FIXME add support for --force option
    if ( -e $tarball_location && -s $tarball_location ) {
        return 1;
    }

    DEBUG("Downloading: $tarball_location");
    $self->http->mirror( $tarball_url, $tarball_location );

    if ( -e $tarball_location && -s $tarball_location ) {
        return 1;
    }

    FAIL("Cannot download tarball from $tarball_url");

    return;
}

sub extract_tarball($self) {
    FATAL("No tarball URL") unless defined $self->distro_url;

    my $tarball = $self->tarball;

    if ( !-e $tarball ) {
        FAIL("No tarball to extract: $tarball");
    }

    my $tmproot       = $self->cli->build_dir or die;
    my $unpacker      = OverPAN::Unpacker->new( tmproot => $tmproot );
    my $relative_path = $unpacker->unpack($tarball);

    FATAL("Fail to extra index tarball: $tarball")
      unless defined $relative_path;

    DEBUG("tarball is extracted to $relative_path");

    my $work_dir = $self->work_dir;
    rmtree($work_dir) if -d $work_dir;
    if ( -e $work_dir ) {
        FAIL("Directory exist and cannot be cleanup: $work_dir");
        return;
    }

    my $extracted_full_path = $tmproot . '/' . $relative_path;
    move( $extracted_full_path, $work_dir ) or do {
        FAIL("Fail to move directory: $extracted_full_path, $work_dir");
        return;
    };

    if ( !-d $work_dir ) {
        FAIL("Fail to extract tarball $tarball to $work_dir");
        return;
    }

    return 1;
}

sub cache_dir($self) {    # ~delegate
    return $self->cli->cache_dir;
}

sub distro_with_version( $self ) {
    return sprintf( '%s@%s',
        $self->distro_name // '?',
        $self->distro_version // '?' );
}

sub set_name_version_url_for_distro ( $self, $distro_or_module ) {
    my $distro = $distro_or_module;
    DEBUG("distro: $distro");

    my $mcpan = MetaCPAN::Client->new();

    my $version;

    # extract the version
    if ( $distro =~ s{\@(.+)$}{} ) {
        $version = $1;
    }

    my $main_module;

    # try to find a distro
    if ( index( $distro, '::' ) == -1 ) {
        if ( !defined $version ) {

            # try to parse the string using CPAN::DistnameInfo
            #   to check if there is a version buried in it
            my $d = CPAN::DistnameInfo->new( $distro_or_module . ".tar.gz" );
            if ( defined $d && defined $d->version && defined $d->dist ) {
                $version = $d->version;
                $self->distro_name( $d->dist );
            }
        }

        if ( !defined $self->distro_name ) {
            eval {
                my $rs = $mcpan->release($distro);
                if ($rs) {
                    $main_module = $rs->main_module;
                    $self->distro_name( $rs->distribution )
                      if defined $rs->distribution;
                    $self->distro_version( $rs->version )
                      if defined $rs->version;
                }
                1;
            } or do {
                ERROR("Cannot find release from $distro");
                DEBUG($@);
                return;
            }
        }
    }

    if ( !$self->distro_name ) {
        eval {
            # fallback to a module if we cannot find a distro
            my $rs = $mcpan->package($distro);
            if ($rs) {
                $self->distro_name( $rs->distribution )
                  if defined $rs->distribution;
                $self->distro_version( $rs->dist_version )
                  if defined $rs->dist_version;
            }
            1;
        } or do {
            ERROR("Cannot find distro/module from $distro_or_module");
            DEBUG($@);
            return;
        }
    }

    if ( !defined $main_module && defined $self->distro_name ) {
        my $rs = $mcpan->release( $self->distro_name );
        $main_module = $rs->main_module if $rs;
    }

    # user requested a specific version
    $self->distro_version($version) if defined $version;

    if ( !defined $main_module ) {
        ERROR("Cannot get main module for $distro_or_module");
        return;
    }

    if ( !defined $self->distro_name ) {
        ERROR("Cannot find distribution name for $distro_or_module");
        return;
    }

    if ( !defined $self->distro_version ) {
        ERROR("Cannot find distribution version for $distro_or_module");
        return;
    }

    my $rs;
    if ( defined $self->distro_version ) {
        $rs = $mcpan->download_url( $main_module, $self->distro_version );
    }
    else {
        $rs = $mcpan->download_url($main_module);
        return unless defined $rs;
        $self->distro_version( $rs->version );
    }
    return unless defined $rs;

    $self->distro_url( $rs->download_url );

    return 1 if $self->distro_url;
    return;
}

# sub _build_xyz                  { 0 }

1;

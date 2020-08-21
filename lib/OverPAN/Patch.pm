package OverPAN::Patch;

use OverPAN;    # make sure INC is set for vendor
use OverPAN::std;
use OverPAN::Logger;

use Simple::Accessor qw{
    cli

    distro_name
    distro_version
    distro_url
};

use CPAN::DistnameInfo ();
use MetaCPAN::Client   ();

sub build ( $self, %options ) {

    #FATAL("OverPAN::Patch needs a cli") unless $options{cli};

    return $self;
}

sub setup ( $self, $distro ) {    # MAYBE move in build...
                                  # create build directory
                                  # download and extract tarball
                                  # git init directory
                                  # apply patches

    # 1. name, version, url
    return unless $self->set_name_version_url_for_distro($distro);


    return 1;
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

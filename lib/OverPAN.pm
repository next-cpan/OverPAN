package OverPAN;

use OverPAN::std;
use OverPAN::Logger;
use OverPAN::Logger::Custom;

BEGIN {
    if ( my $vendor = $INC{'OverPAN.pm'} ) {
        $vendor =~ s{\.pm$}{/vendor};
        unshift @INC, $vendor if -d $vendor;
    }
}

use OverPAN::PatchResult ();
use OverPAN::IPC         ();

use Cwd ();

use File::Basename ();
use File::Which    ();
use File::pushd;

our $VERSION = "0.0001";

use Simple::Accessor qw{
  perl_version
  source
  debug

  src
  cwd
  patch_cmd
};

use OverPAN::Source::Factory;

sub build ( $self, %options ) {

    if ( defined $options{source} && defined $options{perl_version} ) {
        FATAL(
"OverPAN->new 'source' and 'perl_version' are mutually exclusive, use one or the other."
        );
    }

    # FIXME deal with source...
    foreach my $k ( sort keys %options ) {
        $self->{$k} = $options{$k};    # could also use the accessor
    }

    $self->cwd;                        # setup CWD asap
    $self->src or FATAL("Cannot find a source...");

    OverPAN::Logger::enable_debug() if $self->debug;

    return $self;
}

# by default use Perl 7
sub _build_perl_version { int $] }

sub _build_src($self) {
    return OverPAN::Source::Factory->build($self);
}

sub _build_debug { 0 }

sub _build_cwd {
    return Cwd::cwd();
}

sub _build_patch_cmd {
    my $patch = File::Which::which('patch');
    if ( !$patch || !-x $patch ) {
        FATAL("Cannot find 'patch' binary to apply patches.");
    }
    return $patch;
}

sub patch ( $self, $distro = undef, $version = undef, %opts ) {
    my $result = OverPAN::PatchResult->new();

    # capture all log messages while we patch
    my $log = sub ( $class, %opts ) {
        $result->{message} .= "\n"
          if defined $result->{message} && length $result->{message};
        $result->{message} .=
          sprintf( "%s - %s", $opts{type} // '', $opts{message} // '' );
    };
    my $logger = OverPAN::Logger::Custom->new( log => $log );

    # capture `dies` for the end user
    local $@;
    eval { $self->_patch( $result, $distro, $version, %opts ); 1 } or do {

        #$result->success( 0 );
        $result->message($@) if $@;
    };

    return $result;
}

sub _patch ( $self, $result, $distro, $version, %opts ) {

    my $path = delete $opts{path} // $self->cwd;

    if ( scalar keys %opts ) {
        my $extra = join ', ', sort keys %opts;
        FATAL("Unusupported arguments to OverPAN::patch: $extra");
    }

    FATAL("OverPAN::patch: invalid directory $path") unless -d $path;

    if ( !length $distro ) {
        FAIL("Missing distro name when calling patch");
        return;
    }

    if ( !length $version ) {
        FAIL("Missing distro version when calling patch");
        return;
    }

    # Check patches
    my $patches = $self->src->get_patches_for( $distro, $version );

    my $distro_v = qq[$distro\@$version];

    if ( !ref $patches || !scalar $patches->@* ) {
        INFO("No patches for $distro_v");
        $result->success(1);
        return 1;
    }

    my @patches = $patches->@*;

    my $cd_in = pushd($path);
    foreach my $p (@patches) {
        my $short_p = File::Basename::basename($p);
        INFO("Applying patch $short_p for $distro_v");

        my ( $exit, $out, $err ) =
          OverPAN::IPC::run3( [ $self->patch_cmd, '-p1', '-i', $p ] );
        if ( $exit != 0 ) {
            FAIL("Fail to apply patch $short_p to $distro_v");
            DEBUG($out) if length $out;
            ERROR($err) if length $err;
            return;
        }
    }

    my $using_source;
    if ( $self->source ) {
        $using_source = $self->source;
    }
    else {
        $using_source = 'p' . $self->perl_version . '-patches';
    }

    $result->message("Patched $distro_v using OverPAN source: $using_source");
    $result->success(1);
    $result->patched(1);

    return 1;
}

1;

=encoding utf8

=head1 NAME

OverPAN - extra layer on top of CPAN to provide some custom patches

=encoding utf8

=head1 NAME

OverPAN - patch CPAN with some community patches

=head1 SYNOPSIS

    # Create the object and point it to the repo you'll be using.

    # sample usage
    my $o = OverPAN->new( [%attributes] );

    my $result;
    $result = $o->patch( 'Foo-Bar', '1.23' ); # assume Foo-Bar is in '.'
    $result = $o->patch( 'Your-Distro', '4.56', path => q[/path/to/distro] );

    # $result is one OverPAN::PatchResult object
    $result->success; # boolean to check if the patch command succeeds
    $result->patched; # boolean to check if the distro is customized
    $result->message; # string with error or success message

    # You can request to use patches for a specific Perl version
    #   default is the current major Perl version used `int( $] )`
    my $o = OverPAN->new( perl_version => 7 ); 
    my $o = OverPAN->new( perl_version => 5 );

    # or you can point to a local folder with custom patches
    my $o = OverPAN->new( source => '/path/to/patches' );

    # use an alternate GitHub repo
    my $o = OverPAN->new( source => 'https://...' );

    # you can also enable some debugging informations
    my $o = OverPAN->new( debug => 1 ); 

=head1 DESCRIPTION

L<OverPAN> allow to apply some community patches to CPAN distributions
before installing them.

=head1 ATTRIBUTES

List of attributes you can provide to the constructor C<new>.

=head2 perl_version

You can request patches for a specific version of Perl.
Otherwise it will use by default your current perl C<$^X> major version C<int($])>.

Default: current Perl major version (i.e. 5 or 7)

=head2 source

C<source> attribute allow you to use a custom GitHub repository or a custom
path location on your system where patches are stored.

Patches should be created using L<OverPAN::Client>.

=head2 debug

This will enable some extra debug informations available from the L<OverPAN::PatchResult>
message helper.

default: false

=head1 METHODS

=head2 patch( $distro, $version, [%opts] )

Patch a distribution using the namde C<$distro> and the version C<$version>.
This is assuming the files from the distribution are extracted in the current
directory.

    OverPAN->new->patch( 'My-Distro', '1.23' );

If the files are stored in a custom location you can use C<%opts> to specify
where the distribution is stored on disk.

    OverPAN->new->patch( 'My-Distro', '1.23', path => q[/path/to/My-Distro-1.23] );

=head1 Known issues

Probably a lot at this point this is still in active development.

=head1 TODO

=over 4

=item * [ ] write some pod/doc

=item * [ ] write some tests

=back

=head1 COPYRIGHT

Copyright 2020 - Nicolas R.

=head1 LICENSE

This software is licensed under the same terms as Perl.

=head1 CREDITS

=head2 CONTRIBUTORS

Patches and code improvements were contributed by:

=head2 ACKNOWLEDGEMENTS

Bug reports, suggestions and feedbacks were sent by, or general
acknowledgement goes to:

=head1 NO WARRANTY

This software is provided "as-is," without any express or implied
warranty. In no event shall the author be held liable for any damages
arising from the use of the software.

=head1 SEE ALSO

Consider reading the documentation for the command line client

=over 4

=item * L<OverPAN::Client> - the command line tool to create/update patches

Also consider using traditional CPAN Clients:

=over 4

=item * L<App::cpm> - a fast CPAN moduler installer

=item * L<App:cpanm> - get, unpack, build and install modules from CPAN

=item * L<CPAN> - the traditional CPAN client

=item * L<CPANPLUS>

=item * L<pip>

=back

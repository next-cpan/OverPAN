package OverPAN;

use OverPAN::std;
use OverPAN::Logger;

BEGIN {
    if ( my $vendor = $INC{'OverPAN.pm'} ) {
        $vendor =~ s{\.pm$}{/vendor};
        unshift @INC, $vendor if -d $vendor;
    }
}

use OverPAN::IPC ();

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

sub patch ( $self, $distro, $version, %opts ) {

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
        return;
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

    OK("Patched $distro_v using OverPAN source: $using_source");

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
    my $o = OverPAN->new(); 
    $o->patch( 'Foo-Bar', '1.23' ); # assume Foo-Bar is in '.'
    $o->patch( 'Your-Distro', '4.56', path => q[/path/to/distro] );

    # You can request to use patches for a specific Perl version
    #   default is the current major Perl version used `int( $] )`
    my $o = OverPAN->new( perl_version => 7 ); 
    my $o = OverPAN->new( perl_version => 5 );

    # or you can point to a local folder with custom patches
    my $o = OverPAN->new( source => '/path' ); 

    # use an alternate GitHub repo
    my $o = OverPAN->new( source => 'https://...' );

    # you can also enable some debugging informations
    my $o = OverPAN->new( debug => 1 ); 

=head1 DESCRIPTION

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

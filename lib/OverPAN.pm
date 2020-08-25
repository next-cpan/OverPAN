package OverPAN;

use OverPAN::std;
use OverPAN::Logger;

BEGIN {
    if ( my $vendor = $INC{'OverPAN.pm'} ) {
        $vendor =~ s{\.pm$}{/vendor};
        unshift @INC, $vendor if -d $vendor;
    }
}

use Cwd ();
use File::pushd;

our $VERSION = "0.0001";

use Simple::Accessor qw{
  perl_version
  source

  src
  cwd
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

    return $self;
}

# by default use Perl 7
sub _build_perl_version { 7 }

sub _build_src($self) {
    return OverPAN::Source::Factory->build($self);
}

sub _build_cwd {
    return Cwd::cwd();
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

        # FIXME basename
        INFO("Applying patch $p for $distro_v");
    }

    return 1;
}

# # Find distro or package using MetaCPAN::Client
# # Find the version using MetaCPAN::Client if missing

# sub find_distro_and_version( $self, $distro_or_package ) {
#     my ($distro, $version);

#     return ( $distro, $version );
# }

1;

=encoding utf8

=head1 NAME

OverPAN - extra layer on top of CPAN to provide some custom patches

=encoding utf8

=head1 NAME

OverPAN - patch CPAN with some community patches

=head1 SYNOPSIS

    # Create the object and point it to the repo you'll be using.

    # defaults to standard CDN location. 
    my $o = OverPAN->new(); # perl_version => 7

    # default is to use repo for perl 7
    my $o = OverPAN->new( perl_version => 7 ); 
    my $o = OverPAN->new( perl_version => 5 );

    # Point to your local repo you're developing patches in.
    my $o = OverPAN->new( source => '/path' ); 

    # Use an alternate repo
    my $o = OverPAN->new( source => 'https://...' );

    # ... Client extracts tarball ....

    $o->patch( 'Foo-Bar', '1.21', [ path => '.' ] );
    $o->patch( 'Foo-Bar', '1.21', path => '/local/path/to/Foo-Bar' );
    
    sub patch( $self, $distro, $version, %opts = () ) {
    
    }

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

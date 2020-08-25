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

our $VERSION = "0.0001";

use Simple::Accessor qw{
  perl_version
  source

  src
  cwd
};

use OverPAN::Source::Factory;

sub build ( $self, %options ) {

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
    return OverPAN::Source::Factory->create($self);
}

sub _build_cwd {
    return Cwd::cwd();
}

sub patch ( $self, $distro_or_package, %opts ) {

    my $version = delete $opts{version};
    my $path    = delete $opts{path} // $self->cwd;

    FATAL("Unusupported arguments to patch: ") if scalar keys %opts;

    # Find distro or package using MetaCPAN::Client
    my $distro;    # FIXME
                   # Find the version using MetaCPAN::Client if missing

    # Check patches
    $self->source->get_patches_for( distro => $distro, version => $version );

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
    $o->patch('Foo::Bar');  # path = . by default
    $o->patch('Foo::Bar', path => '/local/path/to/Foo-Bar');

    $o->patch('Foo-Bar', version => 1.21, path => '/local/path/to/Foo-Bar' );


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

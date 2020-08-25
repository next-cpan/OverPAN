# NAME

OverPAN - extra layer on top of CPAN to provide some custom patches

# NAME

OverPAN - patch CPAN with some community patches

# SYNOPSIS

```perl
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
```

# DESCRIPTION

# Known issues

Probably a lot at this point this is still in active development.

# TODO

- \[ \] write some pod/doc
- \[ \] write some tests

# COPYRIGHT

Copyright 2020 - Nicolas R.

# LICENSE

This software is licensed under the same terms as Perl.

# CREDITS

## CONTRIBUTORS

Patches and code improvements were contributed by:

## ACKNOWLEDGEMENTS

Bug reports, suggestions and feedbacks were sent by, or general
acknowledgement goes to:

# NO WARRANTY

This software is provided "as-is," without any express or implied
warranty. In no event shall the author be held liable for any damages
arising from the use of the software.

# SEE ALSO

Consider reading the documentation for the command line client

- [OverPAN::Client](https://metacpan.org/pod/OverPAN%3A%3AClient) - the command line tool to create/update patches

    Also consider using traditional CPAN Clients:

    - [App::cpm](https://metacpan.org/pod/App%3A%3Acpm) - a fast CPAN moduler installer
    - [App:cpanm](App:cpanm) - get, unpack, build and install modules from CPAN
    - [CPAN](https://metacpan.org/pod/CPAN) - the traditional CPAN client
    - [CPANPLUS](https://metacpan.org/pod/CPANPLUS)
    - [pip](https://metacpan.org/pod/pip)

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 86:

    &#x3d;over without closing =back

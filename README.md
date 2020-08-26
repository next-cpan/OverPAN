# NAME

OverPAN - extra layer on top of CPAN to provide some custom patches

# NAME

OverPAN - patch CPAN with some community patches

# SYNOPSIS

```perl
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

- Around line 83:

    &#x3d;over without closing =back

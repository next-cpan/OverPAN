# NAME

OverPAN - extra layer on top of CPAN to provide some custom patches

# SYNOPSIS

```perl
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
```

# DESCRIPTION

[OverPAN](https://metacpan.org/pod/OverPAN) allow to apply some community patches to CPAN distributions
before installing them.

# ATTRIBUTES

List of attributes you can provide to the constructor `new`.

## perl\_version

You can request patches for a specific version of Perl.
Otherwise it will use by default your current perl `$^X` major version `int($])`.

Default: current Perl major version (i.e. 5 or 7)

## source

`source` attribute allow you to use a custom GitHub repository or a custom
path location on your system where patches are stored.

Patches should be created using [OverPAN::Client](https://metacpan.org/pod/OverPAN%3A%3AClient).

## debug

This will enable some extra debug informations available from the [OverPAN::PatchResult](https://metacpan.org/pod/OverPAN%3A%3APatchResult)
message helper.

default: false

# METHODS

## patch( $distro, $version, \[%opts\] )

Patch a distribution using the namde `$distro` and the version `$version`.
This is assuming the files from the distribution are extracted in the current
directory.

```
OverPAN->new->patch( 'My-Distro', '1.23' );
```

If the files are stored in a custom location you can use `%opts` to specify
where the distribution is stored on disk.

```perl
OverPAN->new->patch( 'My-Distro', '1.23', path => q[/path/to/My-Distro-1.23] );
```

The return value of `patch` is one [OverPAN::PatchResult](https://metacpan.org/pod/OverPAN%3A%3APatchResult) which allow you
to check if the patch process succeeds and if there were any patches applied.

view [OverPAN::PatchResult](https://metacpan.org/pod/OverPAN%3A%3APatchResult) for more details.

# Known issues

Probably a lot at this point this is still in active development.

# TODO

- \[ \] write some pod/doc
- \[ \] write some tests
- \[ \] support for ~/.overpan.cfg
- \[ \] can set a custom path to patches in configuration: modules/~DISTRO~/~DISTRO~VERSION~
- \[ \] can set a custom path to source in configuration
- \[ \] can set default sources for 5 & 7 in configuration
- \[ \] can set more than a single source for the same Perl version in configuration

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

- Around line 142:

    &#x3d;over without closing =back

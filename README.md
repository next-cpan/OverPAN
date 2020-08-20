# NAME

OverPAN -  extra layer on top of CPAN to provide some custom patches

# NAME

App::overpan -  OverPAN client to patch CPAN

# SYNOPSIS

```
# Patch Distro-v1.00 recipe

> overpan Distro-v1.00
# switch to work-branch
# apply existing patches
HACK HACK
...
> overpan --commit | --abort
```

Run `overpan -h` or `perldoc overpan` for more options.

# DESCRIPTION

# INSTALLATION

## Installing OverPAN

# MANUAL

## Patch a distribution

# USAGE

```
overpan [ACTION] [OPTIONS] [ARGS]
```

## ACTIONS

```
  patch               default action to patch a distributions
  commit              commit patches
  abort               abort current patch process
  test                testing the patches for a distro
  install             installing a distribution with the patches
  help                display this documentation
```

## OPTIONS

## Generic options

```
-v, --verbose            Turns on chatty output
-d, --debug              enable --verbose and display some additional informations
    --color, --no-color  turn on/off color output, default: on
```

# Developer guide

...

# Known issues

Probably a lot at this point this is still in active development.

# TODO

- \[ \] setup GitHub pages
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

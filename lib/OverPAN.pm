package OverPAN;

use OverPAN::std;

BEGIN {
    my $vendor = $INC{'OverPAN.pm'} or die;
    $vendor =~ s{\.pm$}{/vendor};
    unshift @INC, $vendor if -d $vendor;
}

our $VERSION  = "0.0001";

1;

=encoding utf8

=head1 NAME

OverPAN -  extra layer on top of CPAN to provide some custom patches

=encoding utf8

=head1 NAME

App::overpan -  OverPAN client to patch CPAN

=head1 SYNOPSIS

    # Patch Distro-v1.00 recipe

    > overpan Distro-v1.00
    # switch to work-branch
    # apply existing patches
    HACK HACK
    ...
    > overpan --commit | --abort


Run C<overpan -h> or C<perldoc overpan> for more options.

=head1 DESCRIPTION

=head1 INSTALLATION

=head2 Installing OverPAN

=head1 MANUAL

=head2 Patch a distribution

=head1 USAGE

  overpan [ACTION] [OPTIONS] [ARGS]

=head2 ACTIONS

      patch               default action to patch a distributions
      commit              commit patches
      abort               abort current patch process
      test                testing the patches for a distro
      install             installing a distribution with the patches
      help                display this documentation

=head2 OPTIONS

=head2 Generic options

   -v, --verbose            Turns on chatty output
   -d, --debug              enable --verbose and display some additional informations
       --color, --no-color  turn on/off color output, default: on

=head1 Developer guide

...

=head1 Known issues

Probably a lot at this point this is still in active development.

=head1 TODO

=over 4

=item * [ ] setup GitHub pages

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

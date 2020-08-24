package OverPAN::Client::cmd::abort;

use OverPAN::std;

use OverPAN        ();
use OverPAN::Patch ();
use OverPAN::Logger;    # import all

sub run ( $self, @void ) {

    # # abort if no '.git/overpanbuild.json'
    # # or no ENV setup
    # if ( ! OverPAN::Shell::is_in_session() ) {
    #     FAIL "Can only run the abort command in a patch session";
    #     return 1;
    # }

    my $exit_code = !OverPAN::Patch->new( cli => $self )->abort;

    # if run in a shell session exit properly to parent
    OverPAN::Shell->exit($exit_code);

    return $exit_code;
}

1;

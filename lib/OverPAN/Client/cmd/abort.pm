package OverPAN::Client::cmd::abort;

use OverPAN::std;

use OverPAN        ();
use OverPAN::Patch ();
use OverPAN::Logger;    # import all

sub run ( $self, @void ) {

    my $exit_code = !OverPAN::Patch->new( cli => $self )->abort;

    # if run in a shell session exit properly to parent
    OverPAN::Shell->exit($exit_code) if $exit_code == 0;

    return $exit_code;
}

1;

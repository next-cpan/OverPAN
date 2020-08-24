package OverPAN::Client::cmd::commit;

use OverPAN::std;

use OverPAN        ();
use OverPAN::Patch ();
use OverPAN::Logger;    # import all

sub run ( $self, @void ) {
    return !OverPAN::Patch->new( cli => $self )->commit;
}

1;


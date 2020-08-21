package OverPAN::Client::cmd::version;

use OverPAN ();
use OverPAN::std;

sub run ( $self, @argv ) {

    my $version  = $OverPAN::VERSION // 'unknown';
    say "overpan $version";

    return;
}

1;

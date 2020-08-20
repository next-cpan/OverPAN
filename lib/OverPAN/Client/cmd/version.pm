package OverPAN::Client::cmd::version;

use OverPAN::std;

sub run ( $self, @argv ) {

    my $version  = $OverPAN::VERSION // 'DEVEL version';
    say "overpan $version";

    return;
}

1;

package OverPAN::Git;

use OverPAN::std;
use OverPAN::Logger;

use base q[Git::Repository];

sub new ( $class, $dir ) {
    DEBUG("OverPAN::Git->new $dir");

    if ( !-d "$dir/.git" ) {
        DEBUG("init git directory: $dir");
        Git::Repository->run( init => $dir );
    }

    if ( !-d "$dir/.git" ) {
        FATAL("Fail to initialize git repository for $dir");
    }

    my %opts;
    $opts{work_tree} = $dir;

    return $class->SUPER::new(%opts);
}

1;

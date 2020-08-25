package OverPAN;

use OverPAN::std;

BEGIN {
    my $vendor = $INC{'OverPAN.pm'} or die;
    $vendor =~ s{\.pm$}{/vendor};
    unshift @INC, $vendor if -d $vendor;
}

our $VERSION = "0.0001";

1;

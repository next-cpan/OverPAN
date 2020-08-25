package OverPAN::Path;

use OverPAN;    # make sure INC is set for vendor
use OverPAN::std;
use OverPAN::Logger;

sub patch_directory ( $distro_name, $distro_version ) {

    # 'd/distro/v1.00/'
    die unless defined $distro_name    && length $distro_name;
    die unless defined $distro_version && length $distro_version;

    my $first;
    $first = $1 if $distro_name =~ m{^(.)};

    die unless length $first == 1;

    return qq[$first/$distro_name/$distro_version];
}

1;

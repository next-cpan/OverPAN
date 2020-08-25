package OverPAN::Source;

use OverPAN::std;
use OverPAN::Logger;

use OverPAN::Path ();

use Simple::Accessor qw{
  type

  url
  path
};

with 'OverPAN::Roles::JSON';

sub get_patches_for ( $self, $distro, $version ) {
    ...;
}

sub short_path ( $self, $distro, $version ) {    # helper
    return OverPAN::Path::patch_directory( $distro, $version );
}

1;

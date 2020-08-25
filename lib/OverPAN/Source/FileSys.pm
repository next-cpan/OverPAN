package OverPAN::Source::FileSys;

use OverPAN::std;
use OverPAN::Logger;

use File::Find ();

use parent 'OverPAN::Source';

sub get_patches_for ( $self, $distro, $version ) {
    DEBUG("FileSys - get_patches_for distro: $distro version: $version ");

    return unless defined $self->path && -d $self->path;

    my $path = $self->path;
    $path =~ s{/+$}{};
    $path .= '/' . $self->short_path( $distro, $version );

    if ( !-d $path ) {
        DEBUG("No directory $path");
        return;
    }

    my @patches;
    my $wanted = sub {
        my $f = $File::Find::name;

        return unless -f $f && $f =~ m{\.patch$};
        push @patches, $f;
    };

    File::Find::find( { wanted => $wanted, follow => 0 }, $path );

    return \@patches;
}

1;

package OverPAN::Shell;

use OverPAN::std;
use OverPAN::Logger;

use File::pushd qw{pushd};

use Simple::Accessor qw{
  shell
  dir
  _cdin
};

sub build ( $self, %options ) {

    if ( !$options{dir} ) {
        FATAL("Missing dir option in OverPAN::Shell->new");
    }

    $self->_cdin( pushd( $options{dir} ) );
    $self->start();

    return $self;
}

sub _build_shell {
    my $sh = $ENV{SHELL} // '/bin/sh';
    return $sh if defined $sh && -x $sh;

    FATAL("SHELL environment variable not set") unless $ENV{SHELL};
    FATAL("No valid shell found from SHELL environment variable");
}

sub start($self) {
    system( $self->shell );
}

1;

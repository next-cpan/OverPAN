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
    local $ENV{OVERPAN_SHELL} = 1;
    system( $self->shell );
}

sub exit ( $class, $code ) {
    return unless $class->is_in_session;

    INFO("exiting shell session");
    kill( '-KILL' => getppid );

    return;
}

sub is_in_session {
    return !!$ENV{OVERPAN_SHELL};
}

1;

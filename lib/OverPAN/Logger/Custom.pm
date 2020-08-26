package OverPAN::Logger::Custom;

use OverPAN::std;
use OverPAN::Logger;

use Simple::Accessor qw{
  original_log
};

my $_in_progress = 0;

sub build ( $self, %options ) {

    if ( $_in_progress != 0 ) {
        WARN("Already using one instance of OverPAN::Logger::Custom");
    }

    ++$_in_progress;

    my $log = delete $options{log};
    FATAL("log should be a CODE") unless ref $log eq 'CODE';

    $self->original_log( OverPAN::Logger->can('log') );    # store the mock

    {
        no warnings 'redefine';
        *OverPAN::Logger::log = $log;
    }

    return $self;
}

sub DESTROY {
    my ($self) = @_;

    if ( ref $self ) {
        --$_in_progress;
        $_in_progress = 0 if $_in_progress < 0;

        # restore the original log function
        if ( my $log = $self->original_log ) {
            no warnings 'redefine';
            *OverPAN::Logger::log = $log;
        }
    }

    return;
}

1;

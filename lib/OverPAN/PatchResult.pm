package OverPAN::PatchResult;

use OverPAN::std;

use Simple::Accessor qw{
  success
  patched
  message
};

sub build ( $self, %options ) {

    $self->success;
    $self->patched;
    $self->message;

    return $self;
}

sub _build_success { 0 }
sub _build_patched { 0 }
sub _build_message { '' }

1;

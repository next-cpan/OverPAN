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

=encoding utf8

=head1 NAME

OverPAN::PatchResult - result object used by OverPAN

=head1 SYNOPSIS

    my $result = OverPAN::PatchResult->new;

    $result->success; # boolean to check if the patch command succeeds
    $result->patched; # boolean to check if the distro is customized
    $result->message; # string with error or success message

=head1 DESCRIPTION

L<OverPAN::PatchResult> is used by L<OverPAN> to check the status
of a C<patch> request.

=head1 METHODS

=head2 success()

Returns a boolean variable '1' or '0' to know if the patch process succeeds.
Patching a distribution without any patches is considered as a success.
You can then check the C<patched> status to know if there was any patches.

Default: 0

=head2 patched()

Returns a boolean variable '1' or '0' to know if any custom patches were found.

=head2 message()

Returns a string to get more informations about a patch process.
This is used to know the reason of an error or to display a success message.

Default: 0

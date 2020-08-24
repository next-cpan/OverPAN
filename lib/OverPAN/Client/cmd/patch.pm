package OverPAN::Client::cmd::patch;

use OverPAN::std;

use OverPAN ();
use OverPAN::Logger;    # import all

use OverPAN::Patch ();
use OverPAN::Shell ();

sub run ( $self, @distribution ) {

    if ( scalar @distribution == 0 ) {
        FAIL(
"Missing arg: patch action needs one extra argument with a distribution name"
        );
        INFO("Sample: overpan Foo\@v1");
        return 1;
    }
    elsif ( scalar @distribution > 1 ) {
        FAIL(
"Too many args - patch action can only work on a single distribution"
        );
        return 1;
    }

    # only a single distro
    my ($distro) = @distribution;

    # Check that the requested distro/version is ok
    my $patch = OverPAN::Patch->new( cli => $self );
    if ( !$patch->setup($distro) ) {
        FAIL("Cannot setup distribution $distro");
        return 1;
    }

    #INFO(" to ");

    my $distro_with_version = $patch->distro_with_version;

    {
        # start an interactive shell
        INFO(<<"EOS");
Starting a new shell for patching $distro_with_version
- Add, remove, edit patches
- Once ready use 'overpan commit' command to save your patches

At any time you can abort by exiting the current shell session
either type 'exit' or use 'overpan abort' command.
EOS

        my $shell = OverPAN::Shell->new( dir => $patch->work_dir );
    }

    chdir( $self->cwd );

    #DONE("patch succeeds");

    return 0;
}

1;

__END__

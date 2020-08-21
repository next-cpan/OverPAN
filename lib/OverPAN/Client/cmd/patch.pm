package OverPAN::Client::cmd::patch;

use OverPAN::std;

use OverPAN ();
use OverPAN::Patch ();
use OverPAN::Logger; # import all

sub run ( $self, @distribution ) {
    
    if ( scalar @distribution == 0 ) {
        FAIL("Missing arg: patch action needs one extra argument with a distribution name");
        INFO("Sample: overpan Foo\@v1");
        return 1;
    } elsif ( scalar @distribution > 1 ) {
        FAIL("Too many args - patch action can only work on a single distribution");
        return 1;
    }

    # only a single distro
    my ( $distro ) = @distribution;

    # Check that the requested distro/version is ok
    my $patch = OverPAN::Patch->new( cli => $self );    
    $patch->setup( $distro );
    # create build directory
    # download and extract tarball
    # git init directory
    # apply patches

    {
        # start an interactive shell
        #my $shell = OverPAN::Shell->new();
        # 
        1;
    }

    # return 1 unless scalar @modules;

    # my $installer = App::cnext::Installer->new( cli => $self );

    # foreach my $module (@modules) {
    #     if ( $module eq '.' ) {
    #         INFO "Installing distribution from .";
    #         if ( !$installer->install_from_file() ) {
    #             FAIL "Fail to install distribution from .";
    #             return 1;
    #         }
    #         next;
    #     }

    #     INFO("Looking for module: $module");
    #     if ( !$installer->install_single_module_or_repository($module) ) {
    #         FAIL("Fail to install $module or its dependencies.");
    #         return 1;
    #     }
    # }

    DONE("patch  succeeds");

    return 0;
}

1;

__END__

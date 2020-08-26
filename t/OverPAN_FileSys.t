#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';

use OverPAN::std;

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Test::OverPAN::Logger;
use Test::OverPAN::Client;

use File::Copy qw{copy};

use OverPAN::std;

use OverPAN;

use File::Temp;
use File::pushd;

my $tmpdir = File::Temp->newdir();

my $dir_with_patches = $FindBin::Bin . '/fixtures/patches';

ok -d $dir_with_patches, "-d /fixtures/patches";

{
    my $in_tmp = pushd($tmpdir);

    my $o   = OverPAN->new( source => $dir_with_patches );
    my $res = $o->patch( 'Unknown-Distro', 4.56 );

    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 1;
        field patched => 0;
        field message => match qr{\QNo patches for Unknown-Distro@4.56\E};

        etc;
    }, q[nothing to patch for an unknown distro] or diag explain $res;
}

{
    my $in_tmp = pushd($tmpdir);

    my $o   = OverPAN->new( source => $dir_with_patches );
    my $res = $o->patch( 'Simple-Accessor', 1.13 );

    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => match
          qr{\QFail to apply patch 0001.patch to Simple-Accessor@1.13\E};

        etc;
    }, q[fail to patch Simple-Accessor outside of the correct directory]
      or diag explain $res;
}

{
    note "Setup a temp directory with the files";

    my $src = $FindBin::Bin . '/fixtures/distro/Simple-Accessor-1.13';
    ok -d $src, '/fixtures/distro/Simple-Accessor-1.13';

    qx{cp -r $src $tmpdir};
    is $?, 0, "cp -r distro to tmp";

    ok -d "$tmpdir/Simple-Accessor-1.13", 'tmp directory setup';
}

{
    my $in_tmp = pushd("$tmpdir/Simple-Accessor-1.13");
    my $o      = OverPAN->new( source => $dir_with_patches );
    my $res    = $o->patch( 'Simple-Accessor', 1.13 );

    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 1;
        field patched => 1;
        field message => match qr{\QPatched Simple-Accessor@1.13\E};

        etc;
    }, q[patch Simple-Accessor from FileSys] or diag explain $res;
}

done_testing;


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
use File::Path qw(mkpath rmtree);

use OverPAN::std;

use OverPAN;

use File::Temp;
use File::pushd;

my $tmpdir = File::Temp->newdir();

my $dir_with_patches = $FindBin::Bin . '/fixtures/patches';
ok -d $dir_with_patches, "-d /fixtures/patches";

{
    my $in_tmp = pushd($tmpdir);

    my $o = OverPAN->new( source => $dir_with_patches );
    ok !$o->patch( 'Unknown-Distro', 4.56 ),
      'nothing to patch for an unknown distro';
    logger_like(qr{\QNo patches for Unknown-Distro@4.56\E});
}

my $patch_dir = "$tmpdir/my/custom/path";
{
    ok mkpath($patch_dir), 'create /my/custom/path';
    qx{cp -r $dir_with_patches $patch_dir};
    is $?, 0, "cp -r distro to tmp";
    $patch_dir .= '/patches';
    ok -d $patch_dir;
}

{
    my $in_tmp = pushd($tmpdir);
    my $o      = OverPAN->new( source => $patch_dir );
    ok !$o->patch( 'Simple-Accessor', 1.13 ),
      'fail to patch Simple-Accessor outside of the correct directory';
    logger_like(
        qr{FAIL.+\QFail to apply patch 0001.patch to Simple-Accessor@1.13\E});
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
    ok $o->patch( 'Simple-Accessor', 1.13 ),
      'patch Simple-Accessor from FileSys';
    logger_like(qr{OK.+\Qpatched Simple-Accessor@1.13\E});

}

done_testing;


#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';

use OverPAN::std;

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Test::OverPAN::Logger;
use Test::OverPAN::Client;

#use Capture::Tiny ':all';

use OverPAN::std;

use OverPAN;

use File::Temp;
use File::pushd;

my $tmpdir = File::Temp->newdir();

{
    my $o = OverPAN->new();
    is ref $o, 'OverPAN', 'OverPAN object';
    is ref $o->src, 'OverPAN::Source::GitHub',
      'using OverPAN::Source::GitHub object';

    if ( $] < 7 ) {
        is $o->perl_version, 5,
          'default perl_version is depends on current Perl';
        like $o->src->url, qr{^https://github.com/next-cpan/OverPAN-p5-patches},
          'GitHub url';

    }
    else {
        is $o->perl_version, 7,
          'default perl_version is depends on current Perl';
        like $o->src->url, qr{^https://github.com/next-cpan/OverPAN-p7-patches},
          'GitHub url';
    }
}

{
    my $o = OverPAN->new( perl_version => 7 );
    is $o->perl_version, 7, 'we can customize perl_version to use';
}

{
    like(
        dies { OverPAN->new->patch() },
        qr{\QToo few arguments for subroutine 'OverPAN::patch'\E},
        'OverPAN->new->patch without any args'
    );
}

{
    like(
        dies { OverPAN->new->patch('A-Distro') },
        qr{\QToo few arguments for subroutine 'OverPAN::patch'\E},
        'OverPAN->new->patch without any args'
    );
}

{
    ok !OverPAN->new->patch( '', '' ), 'patch with empty args';
    logger_like(qr{Missing distro name when calling patch});
}

{
    ok !OverPAN->new->patch( 'XYZ', '' ), 'patch with empty version only';
    logger_like(qr{Missing distro version when calling patch});
}

{
    ok !OverPAN->new->patch( 'An-Unknown-Distro' => 1.23 ),
      'patch with unknown distro/version: patch( "An-Unknown-Distro" => 1.23 )';
}

{
    Test::OverPAN::Logger::clear_logger();
    my $o = OverPAN->new( perl_version => 7 );
    ok !$o->patch( 'Simple-Accessor', 1.13 ),
      'Fail to patch when not in a directory';
    logger_like(
        qr{FAIL.+\QFail to apply patch 0001.patch to Simple-Accessor\E});
}

my $patch_directory;
{
    my $in_tmp = pushd($tmpdir);

    note "Patch a single distro";
    test_overpan(
        args =>
          [ qq[--cache=$tmpdir], qw{--force --no-shell Simple-Accessor-1.13} ],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{INFO\b.+initialize git directory}i;
                item match qr{INFO\b.+Patch directory:}i;
                etc;
            },
              "missing distro argument"
              or diag explain $lines;

            ok $out->{output} =~ qr{INFO\b.+Patch directory:\s*(.+)$}mi,
              "can find patch directory";
            $patch_directory = $1;
        },
    );
}

ok -d qq[$patch_directory/.git], "we have a pending git directory" or die;

require OverPAN::Git;

my $git = OverPAN::Git->new($patch_directory);
$git->run(qw{reset --hard root});    # not really required

{
    my $in_tmp = pushd($patch_directory);

    my $o = OverPAN->new( perl_version => 7 );
    ok $o->patch( 'Simple-Accessor', 1.13 ), 'patching Simple-Accessor';
    logger_like(qr{OK.+\Qpatched Simple-Accessor\E});
}

done_testing;


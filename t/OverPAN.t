#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Test::OverPAN::Logger;
use Test::OverPAN::Client;

use OverPAN::std;

use OverPAN;

use File::Temp;
use File::pushd;

note $INC{'OverPAN.pm'};

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
    my $res = OverPAN->new->patch();
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => 'FAIL - Missing distro name when calling patch';

        etc;
    }, 'OverPAN->new->patch without any args';
}

{
    my $res = OverPAN->new->patch('A-Distro');
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => 'FAIL - Missing distro version when calling patch';

        etc;
    }, q[OverPAN->new->patch('A-Distro')];
}

{
    my $res = OverPAN->new->patch( '', '' );
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => 'FAIL - Missing distro name when calling patch';

        etc;
    }, q[OverPAN->new->patch('', '')];
}

{
    my $res = OverPAN->new->patch( 'XYZ', '' );
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => 'FAIL - Missing distro version when calling patch';

        etc;
    }, q[OverPAN->new->patch('XYZ', '')];
}

{
    my $res = OverPAN->new->patch( 'An-Unknown-Distro' => 1.23 );
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 1;
        field patched => 0;
        field message => match qr{No patches for An-Unknown-Distro};

        etc;
    }, q[OverPAN->new->patch( 'An-Unknown-Distro' => 1.23 )]
      or diag explain $res;
}

{
    my $res = OverPAN->new( perl_version => 7 )    # .
      ->patch( 'Simple-Accessor', 1.13 );
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => match
          qr{FAIL.+\QFail to apply patch 0001.patch to Simple-Accessor\E};

        etc;
    }, q[Fail to patch when not in a directory] or diag explain $res;
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

#$Test::OverPAN::Logger::DEBUG = 1;
{
    my $in_tmp = pushd($patch_directory);

    my $res = OverPAN->new( perl_version => 7 )    # .
      ->patch( 'Simple-Accessor', 1.13 );
    is $res, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 1;
        field patched => 1;
        field message =>
          q{Patched Simple-Accessor@1.13 using OverPAN source: p7-patches};

        etc;
    }, q[patching Simple-Accessor] or diag explain $res;
}

done_testing;


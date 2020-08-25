#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use Test::OverPAN::Client;

use File::Temp;
use File::Slurper qw{read_text};

{
    note "Patch without arguments";
    test_overpan(
        args => [qw{--patch}],
        exit => 256,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{FAIL\b.+Missing arg};
                etc;
            },
              "missing distro argument";
        },
    );
}

my $tmpdir = File::Temp->newdir();

{
    note "Patch a single distro";
    test_overpan(
        args => [ qq[--cache=$tmpdir], qw{--no-shell Simple-Accessor} ],
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
            my $tmp = $1;
            ok -d $tmp, "tmp directory exits";
            like $tmp, qr{^\Q$tmpdir\E},
              "distro directory is inside tmp directory";

            ok -d qq[$tmp/.git],          "git repository is initialized";
            ok -f qq[$tmp/.overpan.json], ".overpan.json";

            # check files from tarball
            my @files =
              qw{LICENSE README dist.ini lib/Simple/Accessor.pm t/01-basic.t};
            foreach my $f (@files) {
                ok -f qq[$tmp/$f], "$f exits and comes from tarball";
            }
        },
    );
}

{
    note "Patch an older version: ", 'Simple-Accessor@1.11';
    test_overpan(
        args => [ qq[--cache=$tmpdir], qw{--no-shell Simple-Accessor@1.11}, ],
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
            my $tmp = $1;

            ok -d $tmp, "tmp directory exits";
            like $tmp, qr{\Q/Simple-Accessor-1_11\E$},
              "tmp directory contains version: Simple-Accessor-1_11";
            like $tmp, qr{^\Q$tmpdir\E},
              "distro directory is inside tmp directory";

            ok -d qq[$tmp/.git],          "git repository is initialized";
            ok -f qq[$tmp/.overpan.json], ".overpan.json";

            # check files from tarball
            my @files =
              qw{LICENSE README dist.ini lib/Simple/Accessor.pm t/01-basic.t};
            foreach my $f (@files) {
                ok -f qq[$tmp/$f], "$f exits and comes from tarball";
            }

            my $content = read_text(qq[$tmp/lib/Simple/Accessor.pm]);
            like $content, qr{\QVERSION = '1.11';\E}m,
              "got the correct version";
        },
    );
}

done_testing;

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

use File::pushd;

my $tmpdir = File::Temp->newdir();

{
    my $in_tmp = pushd($tmpdir);

    {
        note "abort in a non patch directory";
        test_overpan(
            args => [qw{abort}],
            exit => 256,
            test => sub($out) {
                my $lines = [ split( /\n/, $out->{output} ) ];
                is $lines => bag {
                    item match
qr{FAIL\b.+Current directory does not appear to be a valid OverPAN};
                    etc;
                },
                  "not a valid OverPAN dir for abort"
                  or note explain $out;
            },
        );
    }
}

my $patch_directory;
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
            $patch_directory = $1;
        },
    );
}

ok -d $patch_directory, "got a patch directory" or die;

{
    my $in_tmp = pushd($patch_directory);

    {
        note "abort in a pending patch directory";
        test_overpan(
            args => [qw{abort}],
            exit => 0,
            test => sub($out) {
                my $lines = [ split( /\n/, $out->{output} ) ];
                is $lines => bag {
                    item match qr{INFO\b.+Running action 'abort'};
                    item match qr{INFO\b.+Removing directory};
                    item match
                      qr{OK\b.+Patch aborted for Simple-Accessor-[\d_]+}a;
                    etc;
                },
                  "abort patch session"
                  or note explain $out;
            },
        );
    }
}

done_testing;

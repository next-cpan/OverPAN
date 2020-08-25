#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use Test::OverPAN::Client;

use File::Temp;
use File::Slurper qw{read_text write_text};

use File::pushd;

my $tmpdir = File::Temp->newdir();

# where we want our patches to land
my $rootdir = File::Temp->newdir();

{
    my $in_tmp = pushd($tmpdir);

    {
        note "commit in a non patch directory";
        test_overpan(
            args => [qw{commit}],
            exit => 256,
            test => sub($out) {
                my $lines = [ split( /\n/, $out->{output} ) ];
                is $lines => bag {
                    item match
qr{FAIL\b.+Current directory does not appear to be a valid OverPAN};
                    etc;
                },
                  "not a valid OverPAN dir for commit"
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

    note "commit in a patch directory without patches";
    test_overpan(
        args => [qw{commit}],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{INFO\b.+Running action 'commit'};
                item match qr{INFO\b.+No patches needed for Simple-Accessor};
                etc;
            },
              "commit patch session without patches"
              or note explain $out;
        },
    );
}

{
    my $in_tmp = pushd($rootdir);

    note "Patch a single distro";
    test_overpan(
        args => [ qq[--cache=$tmpdir], qw{--force --no-shell Simple-Accessor} ],
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

    ok -d qq[$patch_directory/.git], "we have a pending git directory" or die;

    require OverPAN::Git;

    my $git = OverPAN::Git->new($patch_directory);

    my $pm_file = qq[$patch_directory/lib/Simple/Accessor.pm];

    # Update a file
    my $original_content = read_text($pm_file);
    my $updated_content  = $original_content;
    like $updated_content, qr{package Simple::Accessor;},
      'package Simple::Accessor';
    $updated_content =~ s{(package [^;]+;)}{$1 use v5;}g;
    isnt $updated_content, $original_content, "add use v5: content has changed";

    write_text( $pm_file, $updated_content );

    # Commit the file
    $git->add('lib/Simple/Accessor.pm');
    $git->commit('add use v5');

    my @out = $git->log('root..');
    is scalar @out, 1, "git log got one entry";
    like $out[0], qr{^\w+ add use v5$}, "commmit message contains 'add use v5'";

    # Add an extra commit
    $updated_content =~ s{(use v5;)}{$1 use strict;}g;
    write_text( $pm_file, $updated_content );
    $git->add('lib/Simple/Accessor.pm');
    $git->commit('add use strict');

    @out = $git->log('root..');
    is scalar @out, 2, "git log got two entries";

    $original_content =~ m{VERSION = '([\d.]+)'};
    my $V = $1;
    ok $V, "Got a version for Simple-Accessor: $V";

    # Commit the patches
    {
        #my $in_tmp = pushd($patch_directory);
        chdir($patch_directory);
        note "commit in a patch directory without patches";
        test_overpan(
            args => [qw{commit -d}],
            exit => 0,
            test => sub($out) {
                my $lines = [ split( /\n/, $out->{output} ) ];
                is $lines => bag {
                    item match qr{INFO\b.+Running action 'commit'};
                    item match
qr{INFO\b.+Updated 2 patches to S/Simple-Accessor/[\d.]+}a;
                    etc;
                },
                  "Updated 2 patches"
                  or note explain $out;

                #note explain $out;
            },
        );
    }

    #note "ROOT: ", $rootdir;
    #note "PWD : ", Cwd::cwd;
    #note qx[find $rootdir];

    ok -e qq[$rootdir/S/Simple-Accessor/$V/patches.json],
      "S/Simple-Accessor/$V/patches.json";
    ok -e qq[$rootdir/S/Simple-Accessor/$V/0001.patch],
      "S/Simple-Accessor/$V/0001.patch";
    ok -e qq[$rootdir/S/Simple-Accessor/$V/0002.patch],
      "S/Simple-Accessor/$V/0002.patch";

    ok !-d $patch_directory, "patch_directory was removed";
}

{
    note "Reapplying the patches";

    my $in_tmp = pushd($rootdir);    # make sure we start from rootdir

    test_overpan(
        args => [ qq[--cache=$tmpdir], qw{--no-shell Simple-Accessor} ],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{INFO\b.+initialize git directory}i;
                item match qr{INFO\b.+\QApply patch 0001.patch\E};
                item match qr{INFO\b.+\QApply patch 0002.patch\E};
                item match qr{INFO\b.+Patch directory:}i;
                etc;
            },
              "re apply patches"
              or diag explain $lines;

            ok $out->{output} =~ qr{INFO\b.+Patch directory:\s*(.+)$}mi,
              "can find patch directory";
            $patch_directory = $1;
        },
    );

    ok -d qq[$patch_directory/.git], "we have a pending git directory" or die;
    my $git = OverPAN::Git->new($patch_directory);
    my @out = $git->log('root..');
    like \@out, array {
        item match qr{add use strict};
        item match qr{add use v5};
    }, "the two patches are reapplied";
}

done_testing;

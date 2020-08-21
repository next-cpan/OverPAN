#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use Test::OverPAN::Client;

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
            }, "missing distro argument";
        },
    );
}

done_testing;

#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use Test::OverPAN::Client;

{
    test_overpan(
        args => [qw{--help}],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{NAME};
                item match qr{SYNOPSIS};
                item match qr{DESCRIPTION};
                item match qr{OPTIONS};
                item match qr{-v, --verbose\s+Turns on chatty output};
                etc;
            }, "--help output";
        },
    );
}

{
    note "help is displayed when no args is provided";
    test_overpan(
        args => [],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => bag {
                item match qr{NAME};
                item match qr{SYNOPSIS};
                item match qr{DESCRIPTION};
                item match qr{OPTIONS};
                item match qr{-v, --verbose\s+Turns on chatty output};
                etc;
            }, "--help output";
        },
    );
}

done_testing;

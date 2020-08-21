#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use Test::OverPAN::Client;

use OverPAN;

my $V = $OverPAN::VERSION;

{
    test_overpan(
        args => [qw{--version}],
        exit => 0,
        test => sub($out) {
            my $lines = [ split( /\n/, $out->{output} ) ];
            is $lines => array {
                item match qr{overpan $V};
                end;
            }, "--version";
        },
    );
}

done_testing;

#!perl

use FindBin;

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Test2::Require::Perl 'v5.20';

use OverPAN;
use OverPAN::std;
use OverPAN::Client;

ok 'load all modules';

done_testing;
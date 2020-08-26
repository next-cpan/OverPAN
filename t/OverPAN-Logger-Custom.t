#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::Logger;    # import debug functions
use Test::OverPAN::Logger;
use OverPAN::Logger::Custom;

use OverPAN::std;

INFO("This is an info message");
logger_like(qr{INFO.+\QThis is an info message\E});

DEBUG("This is a debug message");
logger_like(qr{DEBUG.+\QThis is a debug message\E});

my $original_log = OverPAN::Logger->can('log');

{
    note "Using a custom logger";
    my $msg;
    my $log = sub ( $class, %opts ) {
        my $txt =
          sprintf( "X %s - %s\n", $opts{type} // '', $opts{message} // '' );
        note "# using custom logger: ", $txt;
        $msg .= $txt;
        return;
    };
    my $logger = OverPAN::Logger::Custom->new( log => $log );

    INFO("Another message");
    is $msg, "X INFO - Another message\n", 'using a custom logger';

    isnt( OverPAN::Logger->can('log'), $original_log, "log replaced" );
    is( OverPAN::Logger->can('log'),
        $log, "log replaced by our custom logger function" );
}

INFO("Logger restored");
logger_like(qr{INFO.+\QLogger restored\E});

is( OverPAN::Logger->can('log'), $original_log, "log restored" );

done_testing;


package Test::OverPAN::Logger;

use OverPAN::Logger ();

use Test2::Bundle::Extended;
use Test2::Tools::Explain;

use OverPAN::std;

use Exporter 'import';

our @EXPORT    = qw{logger_like};
our @EXPORT_OK = ( @EXPORT, qw(clear_logger) );

OverPAN::Logger->can('_print') or die "_print does not exist";

our @stack;

{
    no warnings 'redefine';
    *OverPAN::Logger::_print = sub ($s) {
        push @stack, $s;
        note '[OverPAN::Logger]', $s;
    };
}

{
    # setup
    $OverPAN::Logger::COLOR         = -t STDIN ? 1 : 0;
    $OverPAN::Logger::VERBOSE       = 1;
    $OverPAN::Logger::DEBUG         = 1;
    $OverPAN::Logger::SHOW_PROGRESS = 1;
}

sub logger_like(@expect) {
    foreach my $ex (@expect) {
        if ( ref $ex ) {
            like \@stack, bag {
                item match $ex;
                etc;
            }, $ex;
        }
        else {
            like \@stack, bag {
                item match qr{$ex};
                etc;
            }, $ex;
        }
    }

    clear_logger();

    return;
}

sub clear_logger {
    @stack = ();

    return;
}

1;

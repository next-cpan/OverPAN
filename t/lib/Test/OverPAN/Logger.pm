package Test::OverPAN::Logger;

use OverPAN::std;
use OverPAN::Logger ();

use Test::More;

# use Test::MockModule;
# my $mock = Test::MockModule->new( 'OverPAN::Logger' );
# $mock->redefine( _print => sub($s) {
#     note "[LOG] ", $s;
#     return;
# });

OverPAN::Logger->can('_print') or die "_print does not exist";

{
    no warnings 'redefine';
    *OverPAN::Logger::_print = sub ($s) { note '[OverPAN::Logger]', $s };
}

1;

#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;
use OverPAN::PatchResult;

{
    my $result = OverPAN::PatchResult->new;
    is $result, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 0;
        field patched => 0;
        field message => '';

        etc;
    }, 'default PatchResult object set';

    is $result->success, 0,  'success';
    is $result->patched, 0,  'patched';
    is $result->message, '', 'message';
}

{
    my $result = OverPAN::PatchResult->new( success => 1 );
    is $result, object {
        prop blessed => 'OverPAN::PatchResult';

        field success => 1;
        field patched => 0;
        field message => '';

        etc;
    }, 'default PatchResult object set';

    is $result->success, 1,  'success';
    is $result->patched, 0,  'patched';
    is $result->message, '', 'message';
}

{
    my $result = OverPAN::PatchResult->new();

    $result->success(42);
    $result->patched(-1);
    $result->message('custom');

    is $result->success, 42,       'success';
    is $result->patched, -1,       'patched';
    is $result->message, 'custom', 'message';
}
done_testing;

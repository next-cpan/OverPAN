#!perl

use FindBin;
use lib $FindBin::Bin . '/lib';

use OverPAN::std;

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Test::OverPAN::Logger;

#use Capture::Tiny ':all';

use OverPAN::std;

use OverPAN;

{
    my $o = OverPAN->new();
    is ref $o, 'OverPAN', 'OverPAN object';

    is $o->perl_version, 7, 'default perl_version is 7';
    is ref $o->src, 'OverPAN::Source::GitHub',
      'using OverPAN::Source::GitHub object';

    like $o->src->url, qr{^https://github.com/next-cpan/OverPAN-p7-patches},
      'GitHub url';
}

{
    like(
        dies { OverPAN->new->patch() },
        qr{\QToo few arguments for subroutine 'OverPAN::patch'\E},
        'OverPAN->new->patch without any args'
    );
}

{
    like(
        dies { OverPAN->new->patch('A-Distro') },
        qr{\QToo few arguments for subroutine 'OverPAN::patch'\E},
        'OverPAN->new->patch without any args'
    );
}

{
    ok !OverPAN->new->patch( '', '' ), 'patch with empty args';
    logger_like(qr{Missing distro name when calling patch});
}

{
    ok !OverPAN->new->patch( 'XYZ', '' ), 'patch with empty version only';
    logger_like(qr{Missing distro version when calling patch});
}

{
    ok !OverPAN->new->patch( 'An-Unknown-Distro' => 1.23 ),
      'patch with unknown distro/version: patch( "An-Unknown-Distro" => 1.23 )';
}

{
    Test::OverPAN::Logger::clear_logger();
    my $o = OverPAN->new;
    ok $o->patch( 'Simple-Accessor', 1.13 ), 'patching Simple-Accessor';

    #logger_like( qr{Applying patch} );
}

done_testing;


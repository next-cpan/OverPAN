#!perl

use FindBin;
use lib $FindBin::Bin . '/../lib';

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use OverPAN::std;

use OverPAN::Patch;

my $p = OverPAN::Patch->new();
isa_ok $p, 'OverPAN::Patch';

like $INC{'MetaCPAN/Client.pm'}, qr{/vendor/},
  'use MetaCPAN::Client from vendor';

{
    my $distro = 'CPAN-DistnameInfo';
    my $p      = OverPAN::Patch->new();
    ok $p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' )";
    is $p->distro_name,    'CPAN-DistnameInfo', 'distro_name';
    is $p->distro_version, '0.12',              'distro_version';
    is $p->distro_url,
'https://cpan.metacpan.org/authors/id/G/GB/GBARR/CPAN-DistnameInfo-0.12.tar.gz',
      'distro_url';
}

{
    my $distro = 'CPAN::DistnameInfo';
    my $p      = OverPAN::Patch->new();
    ok $p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' )";
    is $p->distro_name,    'CPAN-DistnameInfo', 'distro_name';
    is $p->distro_version, '0.12',              'distro_version';
    is $p->distro_url,
'https://cpan.metacpan.org/authors/id/G/GB/GBARR/CPAN-DistnameInfo-0.12.tar.gz',
      'distro_url';
}

{
    my $distro = 'CPAN-DistnameInfo@0.07';
    my $p      = OverPAN::Patch->new();
    ok $p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' )";
    is $p->distro_name,    'CPAN-DistnameInfo', 'distro_name';
    is $p->distro_version, '0.07',              'distro_version';
    is $p->distro_url,
'https://cpan.metacpan.org/authors/id/G/GB/GBARR/CPAN-DistnameInfo-0.07.tar.gz',
      'distro_url';
}

{
    my $distro = 'CPAN::DistnameInfo@0.07';
    my $p      = OverPAN::Patch->new();
    ok $p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' )";
    is $p->distro_name,    'CPAN-DistnameInfo', 'distro_name';
    is $p->distro_version, '0.07',              'distro_version';
    is $p->distro_url,
'https://cpan.metacpan.org/authors/id/G/GB/GBARR/CPAN-DistnameInfo-0.07.tar.gz',
      'distro_url';
}

{
    my $distro = 'CPAN-DistnameInfo-0.07';
    my $p      = OverPAN::Patch->new();
    ok $p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' )";
    is $p->distro_name,    'CPAN-DistnameInfo', 'distro_name';
    is $p->distro_version, '0.07',              'distro_version';
    is $p->distro_url,
'https://cpan.metacpan.org/authors/id/G/GB/GBARR/CPAN-DistnameInfo-0.07.tar.gz',
      'distro_url';
}

{
    my $distro = 'CPAN::DistnameInfo-0.07';
    note "unsupported syntax: ", $distro;
    my $p = OverPAN::Patch->new();
    ok !$p->set_name_version_url_for_distro($distro),
      "set_name_version_url_for_distro( '$distro' ) fails";
    is $p->distro_name,    undef;
    is $p->distro_version, undef;
    is $p->distro_url,     undef;
}

done_testing;

1;

#!perl
use strict;
use warnings;

requires 'perl', '5.018';

requires 'CPAN::DistnameInfo';
requires 'File::pushd';
requires 'File::Basename';
requires 'File::Slurper';
requires 'File::Which';
requires 'Git::Repository';
requires 'JSON';
requires 'MetaCPAN::Client';
requires 'Simple::Accessor';

on test => sub {
	# continuous integration should only need this	

	requires 'Test::More';
	requires 'Test2::Harness' => '1.000015';

	requires 'Test2::Bundle::Extended' => 0;
	requires 'Test2::Tools::Explain' => 0;
	requires 'Test2::Plugin::NoWarnings' => 0;
	requires 'Test::MockModule' => 0;
};

on develop => sub {
	requires 'Module::Build::Tiny', '0.039';
	requires 'Module::Install';
	requires 'Test::Requires';
	requires 'File::Slurper';

	# for fatpacking
	requires 'App::FatPacker';
	requires 'Perl::Strip';
	requires 'Tie::File';

	recommends 'Archive::Tar';
	recommends 'Archive::Zip';
	recommends 'Compress::Zlib';
	recommends 'File::HomeDir';
	recommends 'LWP::UserAgent', '5.802';
	recommends 'Module::Signature';

	requires 'Carton::Snapshot';
};

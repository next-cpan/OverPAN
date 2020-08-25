package OverPAN::Source::Factory;

use OverPAN::std;
use OverPAN::Logger;

use OverPAN::Source::FileSys ();
use OverPAN::Source::GitHub  ();

our $DEFAULTS_REPO = {
    PERL5 => q[https://github.com/next-cpan/OverPAN-p5-patches],
    PERL7 => q[https://github.com/next-cpan/OverPAN-p7-patches],
};

sub build ( $class, $overpan ) {

    if ( my $url_or_path = $overpan->source ) {
        if ( $url_or_path =~ m{^http.*github\.com}i ) {
            return OverPAN::Source::GitHub->new($url_or_path);
        }
        elsif ( $url_or_path =~ m{^http}i ) {
            FATAL("Do not know how to handle http requests from $url_or_path");
        }

        if ( -d $url_or_path ) {
            return OverPAN::Source::FileSys->new($url_or_path);
        }

        FATAL("Do not know how to build a Source from $url_or_path");
    }
    elsif ( $overpan->perl_version ) {
        if ( !exists $DEFAULTS_REPO->{ $overpan->perl_version } ) {
            FATAL(
                "Do not know which GitHub repository to use for perl_version = "
                  . $overpan->perl_version );
        }

        my $github_url = $DEFAULTS_REPO->{ $overpan->perl_version };
        return OverPAN::Source::GitHub->new($github_url);
    }

    FATAL "Do not know how to build a Source object.";

    return;
}

1;

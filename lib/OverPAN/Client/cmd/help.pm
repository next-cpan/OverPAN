package OverPAN::Client::cmd::help;

use OverPAN::std;
use OverPAN::Client ();

use Pod::Text ();

sub run ( $self, @argv ) {

    my $out;
    open my $fh, ">", \$out;

    my $f = $INC{'OverPAN/Client.pm'};
    $f = $0 unless defined $f && -e $f;

    Pod::Text->new->parse_from_file( $f, $fh );

    if ( defined $out ) {
        $out =~ s/^[ ]{6}/    /mg;
        print STDERR $out;
    }

    return 0;
}

1;

package OverPAN::Roles::JSON;

use OverPAN::std;    # import strict, warnings & features

use JSON ();

use Simple::Accessor qw{json};

sub _build_json($self) {
    return JSON->new->utf8->relaxed->allow_nonref->pretty;
}

1;

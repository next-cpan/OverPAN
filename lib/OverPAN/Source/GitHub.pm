package OverPAN::Source::GitHub;

use OverPAN::std;
use OverPAN::Logger;
use OverPAN::Http;

use parent 'OverPAN::Source';

use File::Temp ();

use Simple::Accessor qw{
  http
  tmp
};

sub _build_http {
    OverPAN::Http->new;
}

sub _build_tmp {
    File::Temp->newdir();
}

sub get_patches_for ( $self, $distro, $version ) {
    DEBUG("get_patches_for distro: $distro version: $version ");

    my $base_url = $self->url;
    $base_url =~ s{/+$}{};    # strip trailing /

    my $path = $self->short_path( $distro, $version );

# https://raw.githubusercontent.com/next-cpan/OverPAN-p7-patches/master/S/Simple-Accessor/1.13/patches.json
# https://github.com/next-cpan/OverPAN-p7-patches/
#   raw/master/S/Simple-Accessor/1.13/patches.json

    my $uri = qq[/raw/master/$path];
    $base_url .= $uri;

    DEBUG("Checking patches.json");
    my $sumup = $self->load_patches_json($base_url);
    return unless ref $sumup;

    return unless $sumup->{patches} && scalar $sumup->{patches}->@*;

    my @patch_files;

    my $c = 0;
    foreach my $p ( $sumup->{patches}->@* ) {
        my $src = $base_url . '/' . $p;

        # do not use the upstream name when creating patches
        my $desti = sprintf( "%s/%04d.patch", $self->tmp, ++$c );

        DEBUG("Downloading $src");
        my $req = $self->http->mirror( $src, $desti );
        if ( !$req->{success} ) {
            FAIL("Fail to download patch $p from $src");
            return;
        }
        push @patch_files, $desti;
    }

    return \@patch_files;
}

sub load_patches_json ( $self, $base_url ) {

    my $url = $base_url . '/patches.json';

    my $req = $self->http->get($url);
    return unless $req->{success} && $req->{status} && $req->{status} == 200;

    my $content = $req->{content};

    return unless defined $content;

    my $data;
    eval {
        $data = $self->json->decode($content);
        1;
    } or do {
        DEBUG("Fail to decode JSON for: ");
        DEBUG($content);
        DEBUG($@);
        return;
    };

    return $data;
}

1;

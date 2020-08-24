package OverPAN::Git;

use OverPAN::std;
use OverPAN::Logger;
use File::Slurper ();

use base q[Git::Repository];

# use Simple::Accessor qw{
#     dir
# };

sub new ( $class, $dir ) {
    DEBUG("OverPAN::Git->new $dir");

    if ( !-d "$dir/.git" ) {
        DEBUG("init git directory: $dir");
        Git::Repository->run( init => $dir );
    }

    if ( !-d "$dir/.git" ) {
        FATAL("Fail to initialize git repository for $dir");
    }

    my %opts;
    $opts{work_tree} = $dir;

    return $class->SUPER::new(%opts);
}

sub add ( $self, @files ) {

    while ( my @next = splice @files, 0, 20 ) {
        $self->run( 'add', @next );
    }

    return;
}

sub commit ( $self, $message ) {
    return $self->run( 'commit', '-m', $message );
}

sub tag ( $self, $tag, $refspec = 'HEAD' ) {

    FATAL("Need to provide a tag name") unless defined $tag;
    $self->run( 'tag', $tag, $refspec );

    return 1;
}

sub setup_gitignore($self) {
    my $content = <<'EOS';
.overpan.json
.DS_Store
Makefile
*.o
blib/
pm_to_blib
.build
*.tar.gz
EOS

    my $work_tree = $self->work_tree or die;
    File::Slurper::write_text( "$work_tree/.gitignore", $content );

    return;
}

sub init($self) {
    INFO("initialize git directory: add .");

    $self->run(qw{config advice.ignoredHook false});

    $self->setup_gitignore;

    # add all files...
    $self->add('.');
    $self->commit('initialize commit');
    $self->tag('root');

    return;
}

sub apply_patch ( $self, $p ) {
    FATAL("apply_patch WIP");
}

1;

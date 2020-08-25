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
    FATAL("Cannot find file $p") unless -f $p;

    $self->run( 'am', $p );
    my $ok = $? == 0;

    FAIL("Fail to apply patch $p") unless $ok;

    return $ok;
}

sub log ( $self, @args ) {

    return $self->run( qw{log --pretty=oneline --abbrev-commit}, @args );
}

sub has_patches( $self ) {

    my @output = $self->log('root..HEAD');
    return scalar @output >= 1 ? 1 : 0;
}

sub format_patches ( $self ) {
    my @patches = $self->run(
        qw{format-patch -a --zero-commit --no-numbered
          --no-signature --diff-algorithm=myers --stat-width=1000
          },
        'root..HEAD',
    );

    return \@patches;
}

1;

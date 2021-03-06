package OverPAN::Client;

use OverPAN::std;    # import strict, warnings & features

use OverPAN::Logger; # import all
use OverPAN::Http;

# need to load all commands to fatpack them
use OverPAN::Client::cmd::abort   ();
use OverPAN::Client::cmd::commit  ();
use OverPAN::Client::cmd::help    ();
use OverPAN::Client::cmd::patch   ();
use OverPAN::Client::cmd::version ();

use Cwd ();

use Simple::Accessor qw{
  name
  http
  cwd

  homedir

  build_dir
  cache_dir

  debug
  verbose
  force
  shell
};

use File::Path qw(mkpath rmtree);

use Getopt::Long qw(:config no_auto_abbrev no_ignore_case bundling);

sub build ( $self, %options ) {

    foreach my $k ( sort keys %options ) {
        $self->{$k} = $options{$k};    # could also use the accessor
    }

    $self->cwd;                        # setup CWD asap

    # defaults values
    my $defaults = {
        check_signature => 1,

        # --with
        with_requires   => 1,
        with_recommends => 0,
        with_suggests   => 0,
        with_configure  => 0,
        with_build      => 1,
        with_test       => 1,
        with_runtime    => 1,
        with_develop    => 0,
    };
    foreach my $k ( sort %$defaults ) {
        $self->{$k} //= $defaults->{$k};
    }

    $self->{features} = [];

    return $self;
}

sub _build_cwd {
    return Cwd::cwd();
}

sub _build_homedir {
    $ENV{HOME} or die q[HOME environmenet variable not set];
}

# we are storing everythink in that directory
#   can be customized using --cache-dir
sub _build_cache_dir($self) {
    my $path = $self->homedir . '/.overpan';
    return $path if -d $path;
    mkpath($path)
      or FATAL("Fail to create ~/.overpan cache directory directory at: $path");
    return $path;
}

sub _build_build_dir($self) {
    my $path = $self->cache_dir . '/build';

    return $path if -d $path;
    mkpath($path) or die "fail to create build directory at: $path";

    return $path;
}

sub DESTROY($self) {

 # # use on purpose the hash accessor to avoid creating the directory on DESTROY
 #    if ( ref $self && $self->{build_dir} && $self->{cleanup} ) {
 #        my $dir = $self->{build_dir};
 #        if ( -d $dir && !-l $dir ) {
 #            DEBUG("rmtree .build directory: $dir");
 #            File::Path::rmtree($dir);
 #        }
 #    }
}

sub _build_http {
    OverPAN::Http->create;
}

sub parse_options ( $self, @opts ) {
    local @ARGV = @opts;

    my $n_tests;

    GetOptions(

        # used
        "color!" => \( $self->{color} ),
        "shell!" => \( $self->{shell} ),

        "f|force"   => \( $self->{force} ),
        "v|verbose" => \( $self->{verbose} ),
        "d|debug"   => \( $self->{debug} ),

        "cache|cache_dir=s" => \( $self->{cache_dir} ),

        "show-progress!" => \( $self->{show_progress} ),
    ) or exit 1;

    $self->{color} = 1 if !defined $self->{color} && -t STDOUT;
    $self->{shell} = 1 if !defined $self->{shell} && -t STDOUT;
    if ( !defined $self->{show_progress} && -t STDOUT ) {
        if ( scalar @ARGV > 1 ) {
            $self->{show_progress} = 1;    # auto hide progress
        }
        else {
# this is making -v behaves differently when installing/testing a single element
            $self->{show_progress} = 0;    # do not delete previous lines
        }
    }

    $self->{show_progress} = 0 if $self->debug;    # no progress on debug
    $self->{show_progress} = 0 unless -t STDIN;

    $self->{run_tests} = 0 if $n_tests;            # alias -n for --no-tests

    $self->{verbose} //= 1;

    # debug enable verbose
    $self->{verbose} = 1 if $self->{debug};

    $self->{cleanup} //= 1;

    $OverPAN::Logger::COLOR         = 1 if $self->{color};
    $OverPAN::Logger::VERBOSE       = 1 if $self->{verbose};
    $OverPAN::Logger::DEBUG         = 1 if $self->{debug};
    $OverPAN::Logger::SHOW_PROGRESS = 1 if $self->{show_progress};

    if ( @ARGV && $ARGV[0] eq "-" ) {
        $self->{argv}     = $self->read_argv_from_stdin;
        $self->{cpanfile} = undef;
    }
    else {
        $self->{argv} = \@ARGV;
    }

    return $self;
}

sub read_argv_from_stdin {
    my $self = shift;
    my @argv;
    while ( my $line = <STDIN> ) {
        next if $line !~ /\S/;
        next if $line =~ /^\s*#/;
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        push @argv, split /\s+/, $line;
    }
    return \@argv;
}

sub get_cmd_sub_for ( $self, $cmd ) {
    return unless defined $cmd;

    $cmd =~ s{^-+}{};
    $cmd =~ s{-}{}g;    # from-tarball -> fromtarball

    # command aliases
    my $aliases = {
        h => 'help',

        #v => 'version',
        V => 'version',
        a => 'abort',
        q => 'abort',
        c => 'commit',
        p => 'patch',
    };

    $cmd = $aliases->{$cmd} if defined $aliases->{$cmd};

    return unless $cmd =~ m{^[A-Za-z0-9_]+$};
    return "OverPAN::Client::cmd::$cmd"->can('run');
}

sub run ( $self, @argv ) {
    my $cmd = '';

    my $default_action = 'patch';

    my $run;
    if ( scalar @argv ) {
        if ( $run = $self->get_cmd_sub_for( $argv[0] ) ) {
            $cmd = shift @argv;
        }
        else {
            $run = $self->get_cmd_sub_for($default_action);
            $cmd = $default_action;
        }
    }
    else {
        $run = $self->get_cmd_sub_for('help');
        $cmd = 'help';
    }

    die qq[Unknown subcommand '$cmd']
      unless defined $run && ref $run eq 'CODE';

    $self->parse_options(@argv);

    $cmd =~ s{^-+}{} if $cmd;
    ## maybe do an extra parse_options for every commands?
    if ( $cmd && $cmd !~ m{^(?:help|version)$} ) {
        INFO("Running action '$cmd'");
    }

    return $run->( $self, @{ $self->{argv} } );
}

1;

=encoding utf8

=head1 NAME

OverPAN::Client - extra layer on top of CPAN to provide some custom patches

=encoding utf8

=head1 NAME

App::overpan -  OverPAN client to patch CPAN

=head1 SYNOPSIS

    # Patch Distro-v1.00 recipe

    > overpan Distro-v1.00
    # switch to work-branch
    # apply existing patches
    HACK HACK
    ...
    > overpan --commit | --abort


Run C<overpan -h> or C<perldoc overpan> for more options.

=head1 DESCRIPTION

=head1 INSTALLATION

=head2 Installing OverPAN

=head1 MANUAL

=head2 Patch a distribution

=head1 USAGE

  overpan [ACTION] [OPTIONS] [ARGS]

=head2 ACTIONS

      patch               default action to patch a distributions
      commit              commit patches
      abort               abort current patch process
      test                testing the patches for a distro
      install             installing a distribution with the patches
      help                display this documentation

=head2 OPTIONS

=head2 Generic options

   -v, --verbose            Turns on chatty output
   -d, --debug              enable --verbose and display some additional informations
       --color, --no-color  turn on/off color output, default: on
       --shell, --no-shell  switch to a custom shell for patching a distro. default: on

=head1 Developer guide

...

=head1 Known issues

Probably a lot at this point this is still in active development.

=head1 TODO

=over 4

=item * [ ] write some pod/doc

=back

=head1 COPYRIGHT

Copyright 2020 - Nicolas R.

=head1 LICENSE

This software is licensed under the same terms as Perl.

=head1 CREDITS

=head2 CONTRIBUTORS

Patches and code improvements were contributed by:

=head2 ACKNOWLEDGEMENTS

Bug reports, suggestions and feedbacks were sent by, or general
acknowledgement goes to:


=head1 NO WARRANTY

This software is provided "as-is," without any express or implied
warranty. In no event shall the author be held liable for any damages
arising from the use of the software.

=head1 SEE ALSO


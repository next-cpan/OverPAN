package OverPAN::Logger;    # stolen from App::cpm::Logger

use OverPAN::std;

use List::Util 'max';

use Exporter 'import';

$| = 1;

our @EXPORT = qw{OK DONE FAIL ERROR WARN INFO DEBUG FATAL};
our @EXPORT_OK =
  ( @EXPORT, qw(fetch resolve install configure build test RUN STDERROR) );

our $COLOR;
our $VERBOSE;
our $DEBUG;
our $SHOW_PROGRESS;

BEGIN { $COLOR = 1 if -t STDIN }

use constant COLOR_RED    => 31;
use constant COLOR_GREEN  => 32;
use constant COLOR_YELLOW => 33;
use constant COLOR_BLUE   => 34;
use constant COLOR_PURPLE => 35;
use constant COLOR_CYAN   => 36;
use constant COLOR_WHITE  => 7;

my %color = (
    FAIL     => COLOR_RED,
    ERROR    => COLOR_RED,      # maybe merge with FAIL ?
    STDERROR => COLOR_RED,      # output from IPC
    FATAL    => COLOR_RED,
    DONE     => COLOR_GREEN,
    OK       => COLOR_GREEN,
    WARN     => COLOR_YELLOW,
    INFO     => COLOR_WHITE,
    DEBUG    => COLOR_WHITE,
    RUN      => COLOR_WHITE,
);

sub new ( $class, @args ) {
    return bless {@args}, $class;
}

sub setup_for_script {
    $VERBOSE       = 1;
    $SHOW_PROGRESS = 0;
    return;
}

sub enable_debug {
    $COLOR         = 1;
    $VERBOSE       = 1;
    $DEBUG         = 1;
    $SHOW_PROGRESS = 0;

    return;
}

sub log ( $self_or_class, %options ) {

    my $type    = $options{type} || "";
    my $message = $options{message};
    chomp $message;

    my $optional = $options{optional} ? " ($options{optional})" : "";
    my $result   = $options{result};
    my $is_color = ref $self_or_class ? $self_or_class->{color} : $COLOR;
    my $verbose  = ref $self_or_class ? $self_or_class->{verbose} : $VERBOSE;
    my $show_progress =
      ref $self_or_class ? $self_or_class->{show_progress} : $SHOW_PROGRESS;

    if ( !$result && $DEBUG ) {
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
          localtime(time);
        $year += 1900;
        $mon++;
        $result = sprintf(
            '[%04d-%02d-%02d %02d:%02d:%02d]',    # .
            $year, $mon, $mday,                   # .
            $hour, $min, $sec,                    # .
        );
    }
    $result //= '';

    if ($is_color) {
        $type   = "\e[$color{$type}m$type\e[m" if $type && $color{$type};
        $result = "\e[$color{$result}m$result\e[m"
          if $result && $color{$result};
        $optional = "\e[1;37m$optional\e[m" if $optional;
    }

    my $eol = $show_progress && !$options{no_progress} ? ""         : "\n";
    my $r   = $show_progress                           ? "\r\033[K" : "";

    my @lines = split( /\n/, $message );

    foreach my $line (@lines) {
        if ($verbose) {

            # type -> 5 + 9 + 3
            $type =
              $is_color && $type
              ? sprintf( "%-17s", $type )
              : sprintf( "%-9s",  $type || "" );
            _print( $r
                  . sprintf( "%s %s %s%s$eol", $result, $type, $line,
                    $optional ) );
        }
        else {
            _print(
                $r
                  . join( " ",
                    map { defined $_ ? $_ : () } $result,
                    $type, $line . $optional )
                  . $eol
            );
        }
    }

    return;
}

sub _print( $s ) {
    print STDERR $s;
    return;
}

# only informations with errors displayed when not using --verbose
sub OK ( $msg, @args ) {

    # always displayed
    return __PACKAGE__->log(
        type        => 'OK',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub DONE ( $msg, @args ) {
    return unless $VERBOSE;
    return __PACKAGE__->log(
        type        => 'DONE',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub DEBUG ( $msg, @args ) {
    return unless $DEBUG;
    return __PACKAGE__->log( type => 'DEBUG', message => $msg, @args );
}

sub RUN ( $msg, @args ) {
    return unless $DEBUG;
    return __PACKAGE__->log( type => 'RUN', message => $msg, @args );
}

sub FAIL ( $msg, @args ) {
    return __PACKAGE__->log(
        type        => 'FAIL',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub ERROR ( $msg, @args ) {
    return __PACKAGE__->log(
        type        => 'ERROR',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub STDERROR ( $msg, @args ) {    # output from IPC run
    return unless $VERBOSE;
    return __PACKAGE__->log(
        type        => 'STDERROR',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub FATAL ( $msg, @args ) {
    __PACKAGE__->log(
        type        => 'FATAL',
        message     => $msg,
        no_progress => 1,
        @args
    );
    die $msg;
}

sub WARN ( $msg, @args ) {
    return unless $VERBOSE;
    return __PACKAGE__->log(
        type        => 'WARN',
        message     => $msg,
        no_progress => 1,
        @args
    );
}

sub INFO ( $msg, @args ) {
    return unless $VERBOSE;
    return __PACKAGE__->log( type => 'INFO', message => $msg, @args );
}

1;

=pod

    use OverPAN::Logger; # DONE INFO FAIL WARN imported

    INFO( "One information" );
    FAIL( "This just failed" );
    WARN( "This is a warning" );

    DONE( "This is now done" );
    DONE( "This is now done", optional => 'xyz' );

    OverPAN::Logger->log(result => "INFO", type => 'DONE', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'FAIL', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'WARN', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'resolve', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'fetch', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'configure', message => 'this is a message');
    OverPAN::Logger->log(result => "INFO", type => 'install', message => 'this is a message');

=cut

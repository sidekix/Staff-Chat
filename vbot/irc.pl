#!/usr/bin/perl -w

use strict;
############################################################
# This is vBot - an IRC bot written in Perl using Net::IRC
#
# The purpose of this bot is to announce new board posts
# and give access to board information in the IRC channel.
#
# The bot is designed to work with current vBulletin release
# but should be portable to other board systems.
#
# Author  : Frank Wittig <frank@lintuxhome.de>
#           (elias5000@jabber.ccc.org)
# License : GPL
# URL     : http://www.elias5000.de/projects/vbot
my $version = "0.5.7-5";
############################################################
$0="vBot $version";

use Net::IRC;
use Getopt::Std;

# it's funny that having an object of this prevents crashing
# in case of invalid XML input in all child processes ;)
use XML::LibXML::Fixup;
my $dont_crash_on_xml_errors = XML::LibXML::Fixup->new();

# config
use lib::config;

# init core modules
use lib::core::log;
use lib::core::statlog;
use lib::core::state;
  lib::core::state->reset();
use lib::core::registry;
  # FIXME: a better way for 1st init of registry db is needed
  lib::core::registry->new();

# store starttime
state_set(BOT_NICKNAME, 'startup', time());
state_set(BOT_NICKNAME, 'version', $version);
debuglog("vBot $version starting up", __FILE__);

############################################################
# setup environment
BEGIN {
  $ENV{PATH} = '/bin:/usr/bin';
  $SIG{CHLD} = \&sigchldHandler;
  $SIG{ALRM} = \&sigalrmHandler;
}

# !!!: overwrite config options only for testing purpose
# get options and catch help request
my %opts;
getopts('c:s:p:n:i:u:d', \%opts);

my $master_pid = $$;
############################################################
# setup and connect
my $irc = new Net::IRC;
my $conn = $irc->newconn(
  Server    => $opts{s} || IRC_SERVER,
  Port      => $opts{p} || IRC_PORT,
  Nick      => $opts{n} || BOT_NICKNAME,
  Ircname   => $opts{i} || BOT_REALNAME,
  Username  => $opts{u} || BOT_USERNAME
);
$conn->{channel} = $opts{c} || IRC_CHANNEL;
$conn->{_debug} = 1 if ($opts{d});

############################################################
# setup handlers
$conn->add_handler('376',           \&on_connect);

$conn->add_handler('msg',           \&on_msg);
$conn->add_handler('notice',        \&on_msg);
$conn->add_handler('public',        \&on_msg);

$conn->add_handler('cversion',      \&on_cversion);
$conn->add_handler('nick',          \&on_nick);

$conn->add_handler('action',        \&statlog);
$conn->add_handler('caction',       \&statlog);
$conn->add_handler('join',          \&statlog);
$conn->add_handler('kick',          \&statlog);
$conn->add_handler('mode',          \&statlog);
$conn->add_handler('part',          \&on_part);
$conn->add_handler('topic',         \&statlog);

$conn->add_handler('cping',         \&on_ping);
$conn->add_handler('nicknameinuse', \&on_nicknameinuse);

############################################################
my $worker = {}; # create background workers
use lib::worker::announce;  $worker->{'announce'} = lib::worker::announce->new($conn);
use lib::worker::heise;     $worker->{'heise'}    = lib::worker::heise->new($conn);
use lib::worker::ping;      $worker->{'ping'}     = lib::worker::ping->new($conn);
use lib::worker::gbo;       $worker->{'gbo'}      = lib::worker::gbo->new($conn);
use lib::worker::caschy;    $worker->{'caschy'}   = lib::worker::caschy->new($conn);
use lib::worker::apfel;     $worker->{'apfel'}    = lib::worker::apfel->new($conn);

############################################################
my $parser = {}; # create command parsers
use lib::parser::nickserv;
  $parser->{'00_nickserv'} = lib::parser::nickserv->new();
use lib::parser::user;
  $parser->{'01_user'} = lib::parser::user->new();

# core features
use lib::parser::commands;
  $parser->{'02_commands'} = lib::parser::commands->new();
use lib::parser::forum;
  $parser->{'03_forum'} = lib::parser::forum->new();

# fun features
use lib::parser::heise;
  $parser->{'11_heise'} = lib::parser::heise->new();
use lib::parser::google;
  $parser->{'12_google'} = lib::parser::google->new();
use lib::parser::quote;
  $parser->{'13_quote'} = lib::parser::quote->new();
use lib::parser::vote;
  $parser->{'14_vote'} = lib::parser::vote->new();
use lib::parser::gbo;
  $parser->{'15_gbo'} = lib::parser::gbo->new();
use lib::parser::info_keys;
  $parser->{'90_infokeys'} = lib::parser::info_keys->new();
use lib::parser::stats;
  $parser->{'91_stats'} = lib::parser::stats->new();
use lib::parser::caschy;
  $parser->{'16_caschy'} = lib::parser::caschy->new();
use lib::parser::apfel;
  $parser->{'17_apfel'} = lib::parser::apfel->new();

# non default
if (HAL_CONVERSATION) {
  use lib::parser::hal;
    $parser->{'99_hal'} = lib::parser::hal->new();
}

# Start action - does not return until disconnect
$irc->start();

# End program execution here
exit;

############################################################
### IRC event handlers

# Connection handler
sub on_connect {
  my $conn = shift;

  $conn->join($conn->{channel});
  $conn->mode(BOT_NICKNAME, "+B") if (BOT_SETBOTMODE);
  $conn->{connected} = 1;
}

# nick change
sub on_nick {
  my ($conn, $event) = @_;

  lib::core::state->event_nick($conn, $event);
  statlog($conn, $event);
}

# part
sub on_part {
  my ($conn, $event) = @_;

  lib::core::state->event_part($conn, $event);
  statlog($conn, $event);
}

# CTCP VERSION
sub on_cversion {
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  $conn->ctcp_reply($sender, sprintf("VERSION vBot %s", $version));
}

# CTCP PING
sub on_ping {
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  alarm(IRC_CHECK_DELAY * 5);
  #debuglog("setting up alarm", __FILE__);

  state_set(BOT_NICKNAME, 'ping', time());
}

# Nickname in use
sub on_nicknameinuse {
  errorlog("[".localtime(time())."] Fatal: Nickname in use.\n", __FILE__);

  # TODO: Do something!!!

  # terminate master process
  kill("TERM", $master_pid);
  waitpid($master_pid, 1);
}

# Message handler
sub on_msg {
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # fork command interpreter
  my $child_pid;
  die "can't fork: $!" unless defined($child_pid = fork());

  unless ($child_pid) { # i am child
    $0="vBot line parser ($sender)";

    # try all parsers until one worked
    my $is_cmd = 0;
    foreach my $curr_parser (sort keys %{$parser}) {
      if ($parser->{$curr_parser}->parse($conn, $event)) {
        $is_cmd = 1;
        last;
      }
    }

    # collect stats from non-commands
    statlog($conn, $event) unless ($is_cmd);

    # i am no longer needed
    kill("TERM", $$);
  }
  # don't wait for child
}

# SIGCHLD handler
sub sigchldHandler {
  wait();
}

sub sigalrmHandler {
  errorlog("got SIGARLM - terminating", __FILE__);

  # terminate master process
  kill("TERM", $$);
  waitpid($$, 1);

  # discontinue execution
  exit;
}

### end of IRC event handlers
############################################################

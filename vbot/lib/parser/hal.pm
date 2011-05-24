package lib::parser::hal;

use strict;
use IO::Socket;

use lib::config;
use lib::core::log;
use lib::core::state;

sub new {
  my $class = shift;

  my $self  = {
  };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 if ($self->conversation($conn, $event));
}

sub conversation {
  my $self  = shift;
  my ($conn, $event) = @_;

  return 0 unless ($event->{type} eq "public");
  return 0 unless (lock('hal_conversation'));

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # connect
  my $client = IO::Socket::INET->new(
    Proto     => "tcp",
    PeerAddr  => HAL_HOST,
    PeerPort  => HAL_PORT
  );
  unless ($client) {
    errorlog("hal connect failed!", __FILE__);
    unlock('hal_conversation');
    return 0;
  }

  my $nick = BOT_NICKNAME;
  my $reply = ($message =~ /^$nick:/);
  $message =~ /^($nick:)?\s*(.*)$/;
  my $question = $2;

  unless ($question) {
    unlock('hal_conversation');
    return 0;
  }

  my $answer = '';

  # communicate
  eval {
    local $SIG{ALRM} = sub {
      errorlog("hal conversation timed out!", __FILE__);
      unlock('hal_conversation');
      return 0;
    };
    alarm 10;
    print $client "$question\n";
    while (my $line = <$client>) {
      $answer .= $line;
    }
    alarm 0;
  };

  # we got a reply
  $answer =~ s/\n/ /g;

  # answer
  if ($reply) {
    $conn->privmsg($conn->{channel}, $answer) if (length $answer);
  }

  unlock('hal_conversation');
  # return success
  return 1;
}

1;

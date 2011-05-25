package lib::parser::nickserv;

use strict;
use lib::config;

sub new {
  my $class = shift;

  my $self  = {
    authenticated => 0
  };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self  = shift;
  my $conn  = shift;
  my $event = shift;

  # shorten things if already authenticated
  return 0 if ($self->{authenticated});

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # try to exit soon
  return 0 unless $sender eq NICKSERV_NAME;
  return 0 unless $message =~ NICKSERV_TRIGGER;

  # authenticate
  $conn->privmsg(NICKSERV_NAME, "IDENTIFY ".NICKSERV_PASSWD);
  # TODO: check response, if successful
  $self->{authenticated} = 1;
  return 1;
}

1;

package lib::parser::caschy;

use strict;
use LWP::Simple;
use XML::RSS;
use Text::Iconv;
use Time::HiRes qw( sleep );

use lib::config;
use constant CASCHY_URI => 'http://feeds2.feedburner.com/stadt-bremerhaven/dqXM?format=xml';

use constant HEISEC_CHARSET    => 'utf-8';

sub new {
  my $class = shift;

  my $self  = {
    iconv => Text::Iconv->new(HEISEC_CHARSET, IRC_CHARSET),
  };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 1 if ($self->caschy($conn, $event));
  return 0 if ($self->help($conn, $event));

  # found none of my commands
  return 0;
}


sub caschy {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!caschy$/i);

  # get and parse RSS feed
  my $feed = get(CASCHY_URI);
  return 0 unless $feed;

  my $rss = new XML::RSS;
  $rss->parse($feed);

  $conn->privmsg($conn->{channel},
    sprintf ("Posting \"%s\": %s",
      $self->{iconv}->convert($rss->{items}[0]->{title}),
      $self->{iconv}->convert($rss->{items}[0]->{link})
  ));
  # return success
  return 1;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!hilfe caschy     - Forum und aktuelle Threads";
  }
  elsif ($message =~ /^!hilfe\s+caschy\b$/i) {
    push @text, "GBO-Kommandos:";
    push @text, "  !caschy          - Link zum letzten Posting";
  }
  else {
    return 0;
  }

  for my $line (@text) {
    $conn->notice($sender, $line);
    sleep IRC_DELAY unless (IRC_FLOOD); # don't flood
  }

  # return success
  return 1;
}

1;


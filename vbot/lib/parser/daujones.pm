package lib::parser::daujones;

use strict;
use LWP::Simple;
use XML::RSS;
use Text::Iconv;
use Time::HiRes qw( sleep );

use lib::config;
use constant DAUJONES_URI => 'http://www.daujones.com/daubeitraege.rss';

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

  return 1 if ($self->daujones($conn, $event));
  return 0 if ($self->help($conn, $event));

  # found none of my commands
  return 0;
}


sub daujones {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!daujones$/i);

  # get and parse RSS feed
  my $feed = get(DAUJONES_URI);
  return 0 unless $feed;

  my $rss = new XML::RSS;
  $rss->parse($feed);

  $conn->privmsg($conn->{channel},
    sprintf ("DJ \"%s\": %s",
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
    push @text, "!hilfe daujones     - Forum und aktuelle Threads";
  }
  elsif ($message =~ /^!hilfe\s+daujones\b$/i) {
    push @text, "DJ-Kommandos:";
    push @text, "  !daujones          - Link zum letzten Posting";
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


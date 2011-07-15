package lib::parser::google;

use strict;
use LWP::Simple;
use XML::RSS;
use Text::Iconv;
use Time::HiRes qw( sleep );

use lib::config;
use constant GOOGLE_URI => 'http://feeds.feedburner.com/insidegoogleplus2011?format=xml';

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

  return 1 if ($self->google($conn, $event));
  return 0 if ($self->help($conn, $event));

  # found none of my commands
  return 0;
}


sub google {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!google$/i);

  # get and parse RSS feed
  my $feed = get(GOOGLE_URI);
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
    push @text, "!hilfe apfel     - Forum und aktuelle Threads";
  }
  elsif ($message =~ /^!hilfe\s+apfel\b$/i) {
    push @text, "Apfeleimer-Kommandos:";
    push @text, "  !apfel          - Link zum letzten Posting";
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


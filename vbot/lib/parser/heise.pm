package lib::parser::heise;

use strict;
use LWP::Simple;
use XML::Atom::Client;
use Time::HiRes qw( sleep );
use Encode;
use String::UTF8 qw( is_utf8 );

use lib::config;
use constant HEISE_OPEN_URI     => {
  title => 'Heise Open',
  url   => 'http://www.heise.de/open/news/news-atom.xml'
};
use constant HEISE_SECURITY_URI => {
  title => 'Heise Security',
  url   => 'http://www.heise.de/security/news/news-atom.xml'
};
use constant SELFHTML_URI => {
  title => 'SELFHTML Aktuell Weblog',
  url   => 'http://aktuell.de.selfhtml.org/weblog/atom-feed'
};
use constant OPENVZ_URI => {
  title => 'OpenVZ Livejournal',
  url   => 'http://openvz.livejournal.com/data/atom/'
};
use constant RUSCERT_URI => {
  title => 'RUS-Cert',
  url   => 'http://cert.uni-stuttgart.de/ticker/rus-cert.xml'
};
use constant WFNEWS_URI => {
  title => 'Winfuture News',
  url   => 'http://static.winfuture.de/feeds/WinFuture-News-atom1.0.xml'
};
use constant WFSEC_URI => {
  title => 'Winfuture Security',
  url   => 'http://static.winfuture.de/feeds/WinFuture-News-Sicherheit-atom1.0.xml'
};
use constant GOLEM_URI => {
  title => 'Golem',
  url   => 'http://rss.golem.de/rss.php?feed=ATOM1.0'
};

use constant HEISE_CHARSET    => 'utf-8';

sub new {
  my $class = shift;

  my $self  = { };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 1 if ($self->heise($conn, $event));
  return 1 if ($self->heisec($conn, $event));
  return 1 if ($self->openvz($conn, $event));
  return 1 if ($self->selfhtml($conn, $event));
  return 1 if ($self->ruscert($conn, $event));
  return 1 if ($self->wfnews($conn, $event));
  return 1 if ($self->wfsec($conn, $event));
  return 1 if ($self->golem($conn, $event));
  return 0 if ($self->help($conn, $event));

  # found none of my commands
  return 0;
}

sub heise {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!heise(\s+)list$/i) {
    return $self->listFeed(HEISE_OPEN_URI, $conn, $event);
  }
  elsif ($message =~ /^!heise(\s+[0-9]+)?$/i) {
    return $self->postEntry(HEISE_OPEN_URI, $conn, $event);
  }
  return 0;
}

sub heisec {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!heisec(\s+)list$/i) {
    return $self->listFeed(HEISE_SECURITY_URI, $conn, $event);
  }
  elsif ($message =~ /^!heisec(\s+[0-9]+)?$/i) {
    return $self->postEntry(HEISE_SECURITY_URI, $conn, $event);
  }
  return 0;
}

sub ruscert {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!ruscert(\s+)list$/i) {
    return $self->listFeed(RUSCERT_URI, $conn, $event);
  }
  elsif ($message =~ /^!ruscert(\s+[0-9]+)?$/i) {
    return $self->postEntry(RUSCERT_URI, $conn, $event);
  }
  return 0;
}

sub wfnews {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!wfnews(\s+)list$/i) {
    return $self->listFeed(WFNEWS_URI, $conn, $event);
  }
  elsif ($message =~ /^!wfnews(\s+[0-9]+)?$/i) {
    return $self->postEntry(WFNEWS_URI, $conn, $event);
  }
  return 0;
}

sub wfsec {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!wfsec(\s+)list$/i) {
    return $self->listFeed(WFSEC_URI, $conn, $event);
  }
  elsif ($message =~ /^!wfsec(\s+[0-9]+)?$/i) {
    return $self->postEntry(WFSEC_URI, $conn, $event);
  }
  return 0;
}

sub golem {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!golem(\s+)list$/i) {
    return $self->listFeed(GOLEM_URI, $conn, $event);
  }
  elsif ($message =~ /^!golem(\s+[0-9]+)?$/i) {
    return $self->postEntry(GOLEM_URI, $conn, $event);
  }
  return 0;
}

sub selfhtml {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!selfhtml(\s+)list$/i) {
    return $self->listFeed(SELFHTML_URI, $conn, $event);
  }
  elsif ($message =~ /^!selfhtml(\s+[0-9]+)?$/i) {
    return $self->postEntry(SELFHTML_URI, $conn, $event);
  }
  return 0;
}


sub openvz {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  if ($message =~ /^!openvz(\s+)list$/i) {
    return $self->listFeed(OPENVZ_URI, $conn, $event);
  }
  elsif ($message =~ /^!openvz(\s+[0-9]+)?$/i) {
    return $self->postEntry(OPENVZ_URI, $conn, $event);
  }
  return 0;
}

sub listFeed {
  my $self  = shift;
  my $url   = shift;
  my ($conn, $event) = @_;

  my $sender  = $event->{nick};

  # get and parse RSS feed
  my $api = XML::Atom::Client->new;
  my $feed = $api->getFeed($url->{url});
  return 0 unless $feed;
  my @entries = $feed->entries;
  return 0 unless scalar @entries;

  $conn->privmsg($conn->{channel}, "Aktuelle Themen bei ".$url->{title}.":");
  sleep IRC_DELAY unless (IRC_FLOOD);

  my $i = 1;
  my $count = 5; # could be made user defined
  foreach my $item (@entries) {
    my $title = $item->title;
    $title = decode(FORUM_CHARSET, $title) unless is_utf8($title);

    my $line = sprintf "(%d) %s", $i, $title;

    # only first 5 to channel more to user
    if ($i <= 5)  { $conn->privmsg($conn->{channel}, $line); }
    else          { $conn->notice($sender, $line); }

    last if ($i++ >= $count);
    sleep IRC_DELAY unless (IRC_FLOOD); # don't flood
  }

  return 1;
}

sub postEntry {
  my $self  = shift;
  my $url   = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my $index = 0;
  if ($message =~ /^!\S+\s+([0-9]+)/i) {
    $index = $1 - 1;
  }

  # get and parse RSS feed
  my $api = XML::Atom::Client->new;
  my $feed = $api->getFeed($url->{url});
  return 0 unless $feed;
  my $entry = ($feed->entries)[$index];
  return 0 unless $entry;

  my $title = $entry->title;
  my $link  = $entry->link->href;
  $title = decode(HEISE_CHARSET, $title) unless is_utf8($title);
  $link  = decode(HEISE_CHARSET, $link)  unless is_utf8($link);

  $conn->privmsg($conn->{channel}, sprintf (
    "Link zum Artikel \"%s\": %s",
    encode(IRC_CHARSET, $title),
    encode(IRC_CHARSET, $link)
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
    push @text, "!hilfe heise     - Heise-Open News";
  }
  elsif ($message =~ /^!hilfe\s+heise\b$/i) {
    push @text, "Heise-Kommandos:";
    push @text, "  !heise  list         - 5 neueste Headlines für Heise Open anzeigen";
    push @text, "  !heise  [<nr>]       - Link für Heise Open anzeigen";
    push @text, "  !heisec  list        - 5 neueste Headlines für Heise Security anzeigen";
    push @text, "  !heisec [<nr>]       - Link für Heise Security anzeigen";
    push @text, "  !selfhtml list       - 5 neueste Headlines f�r Selfhtml Weblog anzeigen";
    push @text, "  !selfhtml [<nr>]	- Link f�r Selfhtml Weblog anzeigen";
    push @text, "  !openvz              - OpenVZ Livejournal";
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

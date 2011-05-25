package lib::parser::forum;

use strict;
use LWP::Simple;
use XML::RSS;
use Encode;
use String::UTF8 qw( is_utf8 );
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;
use lib::core::state;

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

  return 1 if ($self->list($conn, $event));
  return 1 if ($self->link($conn, $event));
  return 1 if ($self->online($conn, $event));
  return 1 if ($self->stats($conn, $event));
  return 0 if ($self->help($conn, $event));

}

sub list {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!list\b( ?(\d+))?/i);
  return 0 unless (lock('forum_list'));
  my $count = $1 || 5; # how many posts to show

  # get and parse RSS feed
  my $feed = state_get(BOT_NICKNAME, 'rss-cache');
  return 0 unless $feed;

  my $rss = new XML::RSS;
  $rss->parse($feed);

  # show them to the user
  my $i = 1;
  $conn->privmsg($conn->{channel}, "Aktuelle ".FORUM_SHORT."-Themen:");
  sleep IRC_DELAY unless (IRC_FLOOD);

  foreach my $item (@{$rss->{'items'}}) {
    my $title = $item->{title};
    $title = decode(FORUM_CHARSET, $title) unless is_utf8($title);

    my $line = sprintf "(%d) %s", $i, $title;

    # only first 5 to channel more to user
    if ($i <= 5)  { $conn->privmsg($conn->{channel}, $line); }
    else          { $conn->notice($sender, $line); }

    last if ($i++ >= $count);
    sleep IRC_DELAY unless (IRC_FLOOD); # don't flood
  }
  unlock('forum_list');
  # return success
  return 1;
}

sub link {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!link\b( ?([\d ]+))?/i);
  return 0 unless (lock('forum_link'));
  my %saw;
  my @numbers = grep(!$saw{$_}++, split(' ', $2 || 1));

  # get and parse RSS feed
  my $feed = state_get(BOT_NICKNAME, 'rss-cache');
  unless ($feed) {
    debuglog('RSS cache empty');
    return 0;
  }

  my $rss = new XML::RSS;
  $rss->parse($feed);

  my $count = 0;
  foreach my $number (@numbers) {
    my $offset = $number - 1;
    next unless defined ($rss->{items}[$offset]);

    # link modifier (used for vbulletins with mod_rewrite-URLs)
    my $title = $rss->{items}[$offset]->{title};
    my $link  = $rss->{items}[$offset]->{link};
    $title = decode(FORUM_CHARSET, $title) unless is_utf8($title);
    $link  = decode(FORUM_CHARSET, $link)  unless is_utf8($link);

    my $search = FORUM_LINK_MOD_S; my $replace = FORUM_LINK_MOD_R;
    $link =~ s/$search/$replace/;

    $conn->privmsg($conn->{channel}, 
      sprintf ("%sLink zum Thema \"%s\": %s",
        (scalar @numbers > 1)?"($number) ":"",
        encode(IRC_CHARSET, $title),
        encode(IRC_CHARSET, $link)
    ));
    last if (++$count >= 5);
    sleep IRC_DELAY unless (IRC_FLOOD);
  }
  unlock('forum_link');
  # return success
  return 1;
}

sub online {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!online$/i);
  return 0 unless (lock('forum_online'));

  # get and parse index page
  my $content   = get(FORUM_INDEX_URI);
  $content =~ m/<tbody id="collapseobj_forumhome_activeusers".*?>(.*?)<\/tbody>/s;

  # TODO: make this code block less hacky
  my $users = $1;
  $users =~ m/<div>(.*?)<\/div>/s;
  $users = $1;
  $users =~ s/<a.*?>(.+?)<\/a>/$1/g;
  $users =~ s/<.+?>//g;
  $users =~ s/, *$//;

  # match numbers
  $content =~ m/\(Registrierte Benutzer: (\d+), G.*?ste: (\d+)\)/s;

  $conn->privmsg($conn->{channel},
    sprintf ("Zur Zeit sind %d registrierte Benutzer (%s) und %d Gäste auf %s aktiv.",
      $1, $users, $2, FORUM_LONG
  ));

  # keep locked for 10 sec.
  sleep 10; unlock('forum_online');
  # return success
  return 1;
}

sub stats {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!stats\b$/i);
  return 0 unless (lock('forum_stats'));

  # get and parse index page
  my $content   = get(FORUM_INDEX_URI);
  $content =~ m/<tbody id="collapseobj_forumhome_stats".*?>(.*?)<\/tbody>/s;
  my $stats = $1;

  # match numbers
  $stats =~ m/Themen: ?([\d\.]+).*?Beitr.*?ge: ?([\d\.]+).*?Benutzer: ?([\d\.]+).*?Benutzer: ?([\d\.]+)/s;

  $conn->privmsg($conn->{channel},
    sprintf ("Es wurden bisher %s Beiträge zu %s Themen verfasst. Von %s Benutzern sind %s aktiv.",
      $2, $1, $3, $4
  ));

  # keep locked for 10 sec.
  sleep 10; unlock('forum_stats');
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
    push @text, "!hilfe forum     - Forum und aktuelle Threads";
  }
  elsif ($message =~ /^!hilfe\s+forum\b$/i) {
    push @text, "Forum-Kommandos:";
    push @text, "  !list [<n>]          - Liste der n aktuellsten Themen";
    push @text, "  !link [<nr> [<nr>]]  - Gibt den Link zu einem Thema aus";
    push @text, "  !online              - Wer ist gerade online?";
    push @text, "  !stats               - Zeige Statistiken";
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

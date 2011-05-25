package lib::worker::announce;

use strict;
use Net::IRC;
use LWP::Simple;
use XML::RSS;
use Encode;
use String::UTF8 qw( is_utf8 );
use Date::Parse qw( str2time );
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;
use lib::core::state;

sub new {
  my $class = shift;

  my $self = {
    conn  => shift, # object:  irc-connection
  };
  bless $self, $class;

  # setup worker process
  $self->{child_pid} = $self->setup();

  return $self;
}

# setup worker process for announcing new posts
sub setup {
  my $self = shift;

  my $last_announced; # holds timestamp of last announced post

  # fork worker process
  my $child_pid;
  return unless defined($child_pid = fork());

  unless ($child_pid) { # i am child
    while(1) {
      $0='vBot RSS worker (active)';

      # get and parse RSS feed
      my $feed = get(FORUM_RSS_URI);
      unless ($feed =~ m/<rss/) {
        debuglog('feed doesn\'t contain rss tag - sleeping for a longer time.', __FILE__);
        # wait 10 minutes
        for (my $i = 10; $i > 0; $i--) {
          $0="vBot RSS worker ...zzzZZZ($i min) [error: invalid RSS]";
          sleep 60;
        }
        next;
      }

      # cache RSS for parser
      errorlog('error writing rss cache', __FILE__) unless state_set(BOT_NICKNAME, 'rss-cache', $feed);

      my $rss = new XML::RSS;
      $rss->parse($feed);

      $last_announced = str2time($rss->{items}[0]->{'pubDate'})
        unless($last_announced);

      my @new_posts;
      foreach my $item (@{$rss->{items}}) {
        unless (str2time($item->{'pubDate'}) <= $last_announced) {
          push @new_posts, $item;
        } else { last };
      }

      # enumerate announces?
      my $enum = (scalar @new_posts > 1);

      while (my $post = pop @new_posts) {
        my $link_id = (scalar @new_posts) + 1;

        my $creator = $post->{dc}->{creator};
        my $title   = $post->{title};
        $creator = decode(FORUM_CHARSET, $creator) unless is_utf8($creator);
        $title   = decode(FORUM_CHARSET, $title)   unless is_utf8($title);

        $self->{conn}->privmsg($self->{conn}->{channel},
          sprintf '%sNeuer Beitrag auf %s von %s: %s',
            ($enum)?"($link_id) ":"",
            FORUM_SHORT,
            encode(IRC_CHARSET, $creator),
            encode(IRC_CHARSET, $title)
        );

        # don't flood
        sleep IRC_DELAY;
      }

      $last_announced = str2time($rss->{items}[0]->{'pubDate'});

      # wait 60 seconds
      for (my $i = 60; $i > 0; $i--) {
        $0="vBot RSS worker ...zzzZZZ($i sec)";
        sleep 1;
      }
    }
    # should not get here - just to be complete ;)
    kill("TERM", $$);
  }
  # return my child's pid
  return $child_pid;
}

# kill worker on exit
sub DESTROY {
  my $self = shift;

  if ($self->{child_pid}) {
    kill("TERM", $self->{child_pid});
    waitpid($self->{child_pid}, 0);
    undef $self->{child_pid};
  }
}

1;

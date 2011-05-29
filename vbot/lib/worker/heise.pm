package lib::worker::heise;

use strict;
use Net::IRC;
use LWP::Simple;
use XML::Atom::Client;
use Encode;
use String::UTF8 qw( is_utf8 );

use lib::config;
use constant HEISE_CHARSET  => 'utf-8';

sub new {
  my $class = shift;

  my $self = {
    conn        => shift, # object:  irc-connection
    heise_urls  => {
      oss => {
        title => 'Heise Open',
        url   => 'http://www.heise.de/open/news/news-atom.xml'
      },
      sec => {
        title => 'Heise Security',
        url   => 'http://www.heise.de/security/news/news-atom.xml'
      },
      selfhtml => {
	title => 'SELFHTML Aktuell Weblog',
	url   => 'http://aktuell.de.selfhtml.org/weblog/atom-feed'
      },
      openvz => {
	title => 'OpenVZ Livejournal',
	url   => 'http://openvz.livejournal.com/data/atom/'
      },
      ruscert => {
	title => 'RUS-Cert',
	url   => 'http://cert.uni-stuttgart.de/ticker/rus-cert.xml'
      },
      wfnews => {
	title => 'Winfuture News',
	url   => 'http://static.winfuture.de/feeds/WinFuture-News-atom1.0.xml'
      },
      wfsecurity => {
	title => 'Winfuture Security',
	url   => 'http://static.winfuture.de/feeds/WinFuture-News-Sicherheit-atom1.0.xml'
      },
      golem => {
	title => 'Golem',
	url   => 'http://rss.golem.de/rss.php?feed=ATOM1.0'
      }
    },
  };
  bless $self, $class;

  # setup worker process
  $self->{child_pid} = $self->setup();

  return $self;
}

# setup worker process for announcing new posts
sub setup {
  my $self = shift;

  my $old_post = { }; # holds timestamp of last announced post

  # fork worker process
  my $child_pid;
  return unless defined($child_pid = fork());

  unless ($child_pid) { # i am child
    while(1) {
      $0='vBot Heise worker (active)';

      # get and parse RSS feed
      foreach my $atom (keys %{$self->{heise_urls}}) {
        # get and parse RSS feed
        my $api = XML::Atom::Client->new;
        my $feed = $api->getFeed($self->{heise_urls}->{$atom}->{url});
        next unless $feed;
        my @entries = $feed->entries;
        next unless scalar @entries;

        my $last_post = $entries[0]->link->href;
        $old_post->{$atom} = $last_post unless($old_post->{$atom});
        if ($last_post ne $old_post->{$atom}) { # new posting has been found
          $old_post->{$atom} = $last_post;

          my $title = $entries[0]->title;
          decode(HEISE_CHARSET, $title) unless is_utf8($title);

          $self->{conn}->privmsg($self->{conn}->{channel},
            sprintf '%s: %s',
              $self->{heise_urls}->{$atom}->{title},
              encode(IRC_CHARSET, $title)
          );
        }
      }

      # wait 10 minutes before next run
      for (my $i = 10; $i > 0; $i--) {
        $0="vBot Heise worker ...zzzZZZ($i min)";
        sleep 60;
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

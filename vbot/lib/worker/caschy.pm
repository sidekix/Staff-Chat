package lib::worker::caschy;

use strict;
use Net::IRC;
use LWP::Simple;
use XML::RSS;
use Text::Iconv;

use lib::config;
use constant CASCHY_URI => 'http://feeds2.feedburner.com/stadt-bremerhaven/dqXM?format=xml';
use constant HEISEC_CHARSET    => 'utf-8';

sub new {
  my $class = shift;

  my $self = {
    conn  => shift, # object:  irc-connection
    iconv => Text::Iconv->new(HEISEC_CHARSET, IRC_CHARSET),
  };
  bless $self, $class;

  # setup worker process
  $self->{child_pid} = $self->setup();

  return $self;
}

# setup worker process for announcing new posts
sub setup {
  my $self = shift;

  my $old_post; # holds timestamp of last announced post

  # fork worker process
  my $child_pid;
  return unless defined($child_pid = fork());

  unless ($child_pid) { # i am child
    while(1) {
      $0='vBot Caschy worker (active)';

      # get and parse RSS feed
      if (my $feed = get(CASCHY_URI)) {

        my $rss = new XML::RSS;
        $rss->parse($feed);

        my $last_post = $rss->{items}[0]->{'link'};
        $old_post = $last_post unless($old_post);      

        if ($last_post ne $old_post) { # new posting has been found
          $old_post = $last_post;

          $self->{conn}->privmsg($self->{conn}->{channel},
            sprintf 'Caschy: %s',
              $self->{iconv}->convert($rss->{items}[0]->{title})
          );
        }
      }

      # wait 10 minutes before next run
      for (my $i = 10; $i > 0; $i--) {
        $0="vBot Caschy worker ...zzzZZZ($i min)";
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


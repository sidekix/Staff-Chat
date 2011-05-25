package lib::worker::ping;

use strict;
use Net::IRC;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;

sub new {
  my $class = shift;

  my $self = {
    conn  => shift, # object:  irc-connection
    pid   => $$
  };
  bless $self, $class;

  # setup worker process
  $self->{child_pid} = $self->setup();

  return $self;
}

# setup worker processes for sending pings and checking response freshness
sub setup {
  my $self = shift;

  # fork worker process
  my $child_pid;
  return unless defined($child_pid = fork());

  unless ($child_pid) { # i am child
    while(1) {
      $0='vBot alive ping (active)';

      # ping me to trigger channel alive check
      $self->{conn}->ctcp('PING', BOT_NICKNAME);

      # wait 60 seconds
      for (my $i = IRC_CHECK_DELAY; $i > 0; $i--) {
        $0="vBot alive ping ...zzzZZZ($i sec)";
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

package lib::parser::user;

use strict;
use POSIX;
use DBI;

use lib::config;
use lib::core::log;
use lib::core::registry;

sub new {
  my $class = shift;

  my $self  = { };
  bless $self, $class;

  return $self;
};

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 if ($self->activity($conn, $event));
  return 1 if ($self->last($conn, $event));
}

sub last {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless($message =~ /^!last\s+(\S+)/i);
  my $nick = $1;

  my $reg = lib::core::registry->new();
  if (my $last = $reg->get(sprintf('user:%s:last_activity', $nick))) {
    my $duration = time() - $last;
    my @up;
    if (my $days = int($duration / (60 * 60 * 24))) {
      $duration = $duration - ($days * 60 * 60 * 24);
      push @up, "$days Tag".(($days > 1)?'en':'');
    }
    if (my $hours = int($duration / (60 * 60))) {
      $duration = $duration - ($hours * 60 * 60);
      push @up, "$hours Stunde".(($hours > 1)?'n':'');
    }
    if (my $minutes = int($duration / 60)) {
      $duration = $duration - ($minutes * 60);
      push @up, "$minutes Minute".(($minutes > 1)?'n':'');
    }

    if (scalar @up) {
      $conn->privmsg($conn->{channel}, sprintf(
        '%s war zuletzt %s in %s aktiv. Das war vor %s',
        $nick,
        strftime('am %A, den %d. %B um %H:%M Uhr', localtime($last)),
        $conn->{channel},
        join(' ', @up)
      ));
    }
    else {
      $conn->privmsg($conn->{channel}, sprintf(
        '%s ist gerade in %s aktiv',
        $nick,
        $conn->{channel}
      ));
    }
  }
  else {
    $conn->privmsg($conn->{channel}, sprintf(
      '%s war noch nie in %s aktiv.',
      $nick,
      $conn->{channel}
    ));
  }

  # return success
  return 1;
}

sub activity {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # write lastlog to registry
  my $reg = lib::core::registry->new();
  $reg->set(sprintf('user:%s:last_activity', $sender), time());

  # don't break $self->parse
  return 0;
}

1;

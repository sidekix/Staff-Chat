package lib::core::statlog;

use strict;
use POSIX;

use lib::config;

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(
  statlog
);

sub statlog {
  my ($conn, $event) = @_;

  my $time = strftime('%d/%m/%Y @ %H:%M:%S', localtime(time()));
  my $timestamp = strftime('%Y%m%d', localtime(time()));

  my $logmessage = "[$time] ";

  # simple cases
  if    ($event->{type} eq "notice")      { return; }
  elsif ($event->{type} eq "msg")         { return; }
  elsif ($event->{type} eq "public")      { $logmessage .= sprintf("<%s> %s", $event->{nick}, $event->{args}[0]); }

  # more sophisticated
  elsif ($event->{type} =~ /^c?action$/) {
    $logmessage .= sprintf("* %s %s",
      $event->{nick},
      join(' ', @{$event->{args}})
    );
  }
  elsif ($event->{type} eq "join") {
    return if ($event->nick eq BOT_NICKNAME);
    $logmessage .= sprintf("*** %s has joined channel %s",
      $event->{nick},
      join(' ', @{$event->{to}})
    );
  }
  elsif ($event->{type} eq "part") {
    return if ($event->nick eq BOT_NICKNAME);
    $logmessage .= sprintf("*** %s has left channel %s",
      $event->{nick},
      join(' ', @{$event->{to}})
    );
  }
  elsif ($event->{type} eq "kick") {
    $logmessage .= sprintf("*** %s has kicked %s",
      $event->{nick}, 
      $event->{to}[0]
    );
  }
  elsif ($event->{type} eq "mode") {
    return unless($event->{user});
    my $args = join(' ', @{$event->{args}});
    $args =~ s/\s$//;
    $logmessage .= sprintf("*** %s sets new mode %s",
      $event->{nick},
      join(' ', @{$event->{args}})
    );
  }
  elsif ($event->{type} eq "nick") {
    return unless($event->{user});
    my $args = join(' ', @{$event->{args}});
    $args =~ s/\s$//;
    $logmessage .= sprintf("*** %s now known as %s",
      $event->{nick},
      $event->{args}[0]
    );
  }
  elsif ($event->{type} eq "topic") {
    return unless($event->{user});
    $logmessage .= sprintf("*** %s has changed topic to %s",
      $event->{nick},
      $event->{args}[0]
    );
  }

  # write to file
  my $fh;
  my $file = "logs/".$conn->{channel}."_$timestamp.log";

  open($fh, ">>$file");
  print $fh $logmessage."\n";
  close($fh);
}

1;

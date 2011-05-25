package lib::parser::info_keys;

use strict;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;

use constant STRINGS_FILE => "lib/info_keys.conf";

sub new {
  my $class = shift;

  my $self  = { };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ( -f STRINGS_FILE );
  return 1 if ($self->infokeys($conn, $event));
  return 1 if ($self->strings($conn, $event));
  return 0 if ($self->help($conn, $event));
}

sub infokeys {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!infokeys\b/i);
  my @keys = sort keys %{$self->get_strings(0)};
  $conn->privmsg($conn->{channel},
    "Info-Keys : ".join(', ', @keys)
  ) if (scalar @keys);

  return 1;
}

sub strings {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!(\S+)/);
  my $command = $1;

  my $strings = $self->get_strings(1);

  return 0 unless (defined $strings->{lc($command)});
  $conn->privmsg($conn->{channel}, $strings->{lc($command)});

  return 1;
}

sub get_strings {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $all = shift || undef;

  # read string definitions
  my $fh;
  unless (open ($fh, "<".STRINGS_FILE)) {
    errorlog("unable to open string command definitions file ".STRINGS_FILE, __FILE__);
    return 0;
  }
  my $strings = {};
  while (my $line = <$fh>) {
    next if ($line =~ /^\s*$/ or $line =~ /^\s*#/);
    next unless $line =~ /^\s*(@?)(\S+)\s+(.*?)\s*$/;
    $strings->{lc($2)} = $3 if (defined $all or not $1);
  }
  close $fh;

  return $strings;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!infokeys        - Listet alle Info-Keys";
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

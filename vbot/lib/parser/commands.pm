package lib::parser::commands;

use strict;
use POSIX;
use LWP::Simple;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;
use lib::core::state;
use lib::core::registry;

sub new {
  my $class = shift;

  my $self  = {
    conn      => shift, # object:  irc-connection
    pid       => $$
  };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # public commands
  return 1 if ($self->hello($conn, $event));
  return 1 if ($self->rot13($conn, $event));
  return 1 if ($self->uptime($conn, $event));

  # owner only commands
  my $admins = BOT_ADMINS;
  return 0 unless (grep(/^$sender$/i, keys %{$admins}));
  return 1 if ($self->login($conn, $event));
  return 0 if ($self->help($conn, $event));
  return 1 if ($self->debug($conn, $event));

  # logged in only commands
  my $from = state_get($sender, 'login') || 'invalid';
  return 0 unless ($event->{from} eq $from);
  return 1 if ($self->say($conn, $event));
  return 1 if ($self->die($conn, $event));

  # found none of my commands
  return 0;
}

sub hello {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!h(a|e)llo\b/i);

  $conn->privmsg($conn->{channel}, sprintf("Hallo %s", $sender));
  # return success
  return 1;
}

sub rot13 {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!rot13\s*(.*)$/i);
  my $string = $1;

  $string =~ tr/A-Za-z/N-ZA-Mn-za-m/;
  $conn->notice($sender, sprintf('<%s> %s', $sender, $string));

  # return success
  return 1;
}

sub uptime {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!uptime\b/i);

  my $uptime = time - state_get(BOT_NICKNAME,'startup');
  my @up;
  if (my $days = int($uptime / (60 * 60 * 24))) {
    $uptime = $uptime - ($days * 60 * 60 * 24);
    push @up, "$days Tag".(($days > 1)?'e':'');
  }
  if (my $hours = int($uptime / (60 * 60))) {
    $uptime = $uptime - ($hours * 60 * 60);
    push @up, "$hours Stunde".(($hours > 1)?'n':'');
  }
  if (my $minutes = int($uptime / 60)) {
    $uptime = $uptime - ($minutes * 60);
    push @up, "$minutes Minute".(($minutes > 1)?'n':'');
  }

  $conn->privmsg($conn->{channel},
    sprintf("vBot %s uptime: %s",
      state_get(BOT_NICKNAME, 'version'),
      join(' ', @up)
  )) if (scalar @up);

  # return success
  return 1;
}

sub login {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!login\s*(.*)$/i);
  my $password = $1;

  my $admins = BOT_ADMINS;
  return 0 unless (crypt($1, 'vb') eq $$admins{$sender});

  $conn->notice($sender, "Hallo $sender! Du bist jetzt eingeloggt.");
  state_set($sender, 'login', $event->{from});

  # return success
  return 1;
}

sub say {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!say (.*)$/i);

  $conn->privmsg($conn->{channel}, $1);

  # success
  return 1;
}

sub debug {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!debug ([01])$/i);

  my $reg = new lib::core::registry();
  if ($1 == '1') {
    $conn->notice($sender, 'debug an') if $reg->set('log_debug', 'on');
  }
  else {
    $conn->notice($sender, 'debug aus') if $reg->unset('log_debug');
  }

  # success
  return 1;
}

sub die {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!die\b/i);
  $conn->privmsg($conn->{channel},
    "Terminating on request. Bye everybody...");

  # terminate master process
  kill("TERM", $self->{pid});
  waitpid($self->{pid}, 1);

  # discontinue execution
  exit;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!hilfe owner     - Administration";
  }
  elsif ($message =~ /^!hilfe\s+owner\b$/i) {
    push @text, "Owner-Kommandos:";
    push @text, "  !login <passwd>      - Als Bot-Admin anmelden";
    push @text, "  !say <text>          - Schreibt <text> in den Channel";
    push @text, "  !die                 - Haupt-Prozess beenden";
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

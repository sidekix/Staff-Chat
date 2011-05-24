package lib::parser::vote;

use strict;
use POSIX;
use DBI;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::state;

use constant DATABASE => "data/vote.db";
use constant DURATION => 2;

sub new {
  my $class = shift;

  # connect database
  my $exists    = ( -f DATABASE );
  my $dsn       = "dbi:PgLite:dbname=".DATABASE;

  my $self  = {
    conn      => shift, # object:  irc-connection
    dbh       => DBI->connect($dsn)
  };
  bless $self, $class;

  # init database if required
  $self->init_db() unless ($exists);

  # prapare statements
  $self->{_sth_clean} = $self->{dbh}->prepare("DELETE FROM votes");
  $self->{_sth_voted} = $self->{dbh}->prepare("
    SELECT 1 FROM votes WHERE nick=? OR hostmask=?
  ");
  $self->{_sth_get_vote} = $self->{dbh}->prepare("
    SELECT
      (
        SELECT COUNT(1) FROM votes WHERE id = ?
      ) AS count,
      (
        SELECT COUNT(1) FROM votes
      ) AS total
    ");
  $self->{_sth_vote} = $self->{dbh}->prepare("
    INSERT INTO
      votes
    (id,  nick, hostmask)
    VALUES (?, ?, ?)
  ");

  return $self;
}

sub init_db {
  my $self = shift;
  # Table quotes
  $self->{dbh}->do('
    CREATE TABLE votes (
      id        integer NOT NULL,
      nick      NOT NULL UNIQUE,
      hostmask  NOT NULL UNIQUE
    );');
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 1 if ($self->mkpoll($conn, $event));
  return 1 if ($self->vote($conn, $event));
  return 0 if ($self->help($conn, $event));

}

sub vote {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!vote\s+(\d+)$/i);

  # block multiple calls
  $self->{_sth_voted}->execute($sender, $event->{from});
  return 0 if ($self->{_sth_voted}->fetchrow_hashref());

  # vote
  $self->{_sth_vote}->execute($1, $sender, $event->{from});
  $conn->notice($sender, "Deine Wahl wurde registriert.");

  # return success
  return 1;
}

sub mkpoll {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!mkpoll\s+(.*)$/i);
  my @answers = split(/\s*;\s*/, $1);
  $self->{question} = shift @answers;

  $self->{answers} = {};
  for my $answer (@answers) {
    $self->{answers}->{(scalar keys %{$self->{answers}})+1} = $answer;
  }

  return 0 unless (
        scalar keys %{$self->{answers}} >= 2
    and scalar keys %{$self->{answers}} <= 10
  );
  # lock for action
  return 0 unless (lock('poll'));
  $0 = "vBot poll ($sender)";

  # init vote counter
  $self->{_sth_clean}->execute();

  # announce poll
  my   @text;
  push @text, ". o O ( Neue Abstimmung von $sender ) O o .";
  push @text, "Frage: ".$self->{question};
  for my $key (sort keys %{$self->{answers}}) {
    push @text, sprintf("(%d) %s", $key, $self->{answers}{$key});
  }
  
  push @text, "Vote-Command: !vote <nr>"; 
  push @text, "Anonymes Voten mit: /MSG ".BOT_NICKNAME." !vote <nr>";
  push @text, "Jeder kann nur einmal voten - der Poll läuft ".DURATION." Min.";
  for my $line (@text) {
    $conn->privmsg($conn->{channel}, $line);
    sleep IRC_DELAY unless (IRC_FLOOD); # don't flood
  }

  # sleep vote duration
  $0 = "vBot poll ($sender) ...zzzZZZ";
  sleep DURATION * 60;
  $0 = "vBot poll ($sender)";

  # announce result
  @text = '';
  push @text, ". o O ( Ergebnis der Abstimmung von $sender ) O o .";
  push @text, "Frage: ".$self->{question};

  # get poll result
  my $result;
  my $total;
  for my $key (keys %{$self->{answers}}) {
    $self->{_sth_get_vote}->execute($key);
    my $row = $self->{_sth_get_vote}->fetchrow_hashref();
    $result->{$key} = $row->{count};
    $total = $total || $row->{total};
  }


  # display results
  if ($total > 0) {
    my $valid = 0;
    for my $key (reverse sort {$result->{$a} cmp $result->{$b}} keys %{$result}) {
      push @text, sprintf("%d%% - %s",
        (($total > 0) ? ($result->{$key} * 100 / $total) : 0),
        $self->{answers}{$key}
      );
      $valid += $result->{$key};
    }
    # calculate invalid votes
    my $invalid = $total - $valid;
    push @text, sprintf("Es wurde%s %s%s%s Stimme%s abgegeben.",
      ($total > 1)?'n':'',
      ($valid > 0)?"$valid gültige":'',
      ($valid > 0 and $invalid > 0)?" und ":'',
      ($invalid > 0)?"$invalid ungültige":'',
      ($total > 1)?'n':'',
    );
  }
  else {
    push @text, "Es wurden keine Stimmen abgegeben.";
  }

  for my $line (@text) {
    $conn->privmsg($conn->{channel}, $line);
    sleep IRC_DELAY unless (IRC_FLOOD); # don't flood
  }

  # return success
  unlock('poll');
  return 1;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!hilfe vote      - Abstimmungen";
  }
  elsif ($message =~ /^!hilfe\s+vote\b$/i) {
    push @text, "Vote-Kommandos:";
    push @text, "  !mkpoll <Frage>; <Antwort 1>; <Antwort 2>; ...";
    push @text, "                       - Startet einen neuen Poll";
    push @text, "  !vote [<n>]          - abstimmen";
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

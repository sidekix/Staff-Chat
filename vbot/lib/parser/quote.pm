package lib::parser::quote;

use strict;
use POSIX;
use DBI;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::state;

use constant DATABASE => "data/quote.db";

sub new {
  my $class = shift;

  # connect database
  my $exists    = ( -f DATABASE );
  my $dsn       = "dbi:PgLite:dbname=".DATABASE;

  my $self  = {
    dbh       => DBI->connect($dsn)
  };
  bless $self, $class;

  # init database if required
  $self->init_db() unless ($exists);

  return $self;
}

sub init_db {
  my $self = shift;
  # Table quotes
  $self->{dbh}->do('
    CREATE TABLE quotes (
      id      integer UNIQUE NOT NULL,
      time    timestamp with timezone NOT NULL,
      creator NOT NULL,
      text    NOT NULL
    );');
}

sub parse {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # public commands
  return 1 if ($self->quote($conn, $event));
  return 1 if ($self->randquote($conn, $event));
  return 1 if ($self->addquote($conn, $event));
  return 0 if ($self->help($conn, $event));

  # owner only commands
  my $admins = BOT_ADMINS;
  return 0 unless (grep(/^$sender$/i, keys %{$admins}));

  my $from = state_get($sender, 'login') || 'invalid';
  return 0 unless ($event->{from} eq $from);

  return 1 if ($self->delquote($conn, $event));

  # found none of my commands
  return 0;
}

sub quote {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!quote (\d+)$/i);
  my $id = $1;

  # fetch quote from db
  my $sth = $self->{dbh}->prepare('
    SELECT *, EXTRACT(EPOCH FROM time) AS unixtime
    FROM quotes
    WHERE id=?
  ');
  $sth->execute($id);
  if (my $quote = $sth->fetchrow_hashref()) {
    $conn->privmsg($conn->{channel},
      sprintf("(%d) %s [added %s by %s]",
      $quote->{id},
      $quote->{text},
      strftime('%H:%M %d.%m.%Y', localtime($quote->{unixtime})),
      $quote->{creator}
    ));
  }
  $sth->finish();

  # success
  return 1;
}

sub randquote {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!randquote$/i);
  my $id = $1;

  # fetch quotes from db
  my $sth = $self->{dbh}->prepare(
    'SELECT *, EXTRACT(EPOCH FROM time) AS unixtime FROM quotes');
  $sth->execute();
  my @quotes;
  while (my $quote = $sth->fetchrow_hashref()) {
    push @quotes, $quote;
  }
  $sth->finish();
  return 0 unless (scalar @quotes);

  my $rand_id = rand(scalar @quotes);

  $conn->privmsg($conn->{channel},
    sprintf("(%d) %s [added %s by %s]",
    $quotes[$rand_id]->{id},
    $quotes[$rand_id]->{text},
    strftime('%H:%M %d.%m.%Y', localtime($quotes[$rand_id]->{unixtime})),
    $quotes[$rand_id]->{creator}
  ));

  # success
  return 1;
}

sub addquote {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  # extract quote, trim and exit if blank
  return 0 unless ($message =~ /^!addquote (.+)$/i);
  my $quote = $1;
  for ($quote) { s/^(\s+)//; s/(\s+)$//; }
  return 0 unless (scalar $quote);

  $self->{dbh}->begin_work;
  my $sth = $self->{dbh}->prepare("
    INSERT INTO quotes
    (
      id,
      time,
      creator,
      text
    )
    VALUES (
      (COALESCE((SELECT MAX(id) FROM quotes), 0) + 1),
      now(),
      ?,
      ?
    )");

  if ($sth->execute($sender, $quote)) {
    my $id = $self->{dbh}->selectrow_array("SELECT MAX(id) FROM quotes");
    $conn->notice($sender,
      sprintf("Zitat als #%d eingefügt",
      $id
    ));
    $sth->finish();
    $self->{dbh}->commit;
  }
  else {
    $sth->finish();
    $self->{dbh}->rollback;
  }

  # success
  return 1;
}

sub delquote {
  my $self = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!delquote (\d+)$/i);
  my $id = $1;

  my $sth = $self->{dbh}->prepare("DELETE FROM quotes WHERE id=?");
  if ($sth->execute($id)) {
    $conn->notice($sender,
      sprintf("Zitat #%d gelöscht",
      $id
    ));
  }
  $sth->finish();

  # success
  return 1;
}

sub cgi_get_all {
  my $self = shift;

  my @quotes;
  my $sth = $self->{dbh}->prepare(
    "SELECT *, EXTRACT(EPOCH FROM time) AS unixtime FROM quotes");
  $sth->execute();
  while (my $row = $sth->fetchrow_hashref()) {
    push @quotes, $row;
  }
  $sth->finish();
  return @quotes;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!hilfe quote     - Hilfe zu den Quote-Kommandos";
  }
  elsif ($message =~ /^!hilfe\s+quote\b$/i) {
    push @text, "Quote-Kommandos:";
    push @text, "  !quote <nr>          - Gibt Quote #<nr> aus";
    push @text, "  !randquote           - Gibt ein zufälliges Zitat aus";
    push @text, "  !addquote <text>     - Fügt ein Quote hinzu";

    # owner only commands
    my $admins = BOT_ADMINS;
    if (grep(/^$sender$/i, keys %{$admins})) {
      push @text, "  !delquote <nr>       - Löscht Quote #<nr>";
    }
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

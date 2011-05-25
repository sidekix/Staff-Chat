package lib::parser::stats;

use strict;
use DBI;

use lib::config;
use lib::core::log;

use constant DATABASE => "data/stats.db";

sub new {
  my $class = shift;

  # connect database
  my $exists    = ( -f DATABASE );
  my $dsn       = "dbi:PgLite:dbname=".DATABASE;

  my $self  = {
    dbh         => DBI->connect($dsn)
  };
  bless $self, $class;

  # init database if required
  $self->init_db() unless ($exists);

  # prepare some statements
  $self->{_sth_get}  = $self->{dbh}->prepare('SELECT * FROM stats WHERE username=?');
  $self->{_sth_new}     = $self->{dbh}->prepare('
    INSERT INTO stats
    (username, words, chars, smileys)
    VALUES (?, ?, ?, ?)
  ');
  $self->{_sth_update}  = $self->{dbh}->prepare('
    UPDATE stats
    SET
      words   = words   + ?,
      chars   = chars   + ?,
      smileys = smileys + ?
    WHERE
      username = ?
  ');
  $self->{_sth_toplist} = $self->{dbh}->prepare('
    SELECT *
    FROM stats
    ORDER BY words DESC
    LIMIT 10
  ');

  return $self;
}

sub init_db {
  my $self = shift;
  # Table quotes
  $self->{dbh}->do('
    CREATE TABLE stats (
      username  text UNIQUE NOT NULL,
      words     integer,
      chars     integer,
      smileys   integer
    );');
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 1 if ($self->top($conn, $event));
  return 1 if ($self->stat($conn, $event));
  return 0 if ($self->count($conn, $event));
}

sub top {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!top\b/i);

  my @toplist;
  $self->{_sth_toplist}->execute();
  while (my $row = $self->{_sth_toplist}->fetchrow_hashref()) {
    push @toplist, sprintf('%d. %s (%d)',
      scalar @toplist + 1,
      $row->{username},
      $row->{words}
    );
  }

  $conn->privmsg($conn->{channel}, sprintf(
    'Top10 (Wörter): %s',
    join(', ', @toplist)
  ));

  # return success
  return 1;
}

sub stat {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!stat\b\s*(\S*)/i);

  my $user = $1 || $sender;
  
  $self->{_sth_get}->execute($user);
  if (my $row = $self->{_sth_get}->fetchrow_hashref()) {
    $conn->privmsg($conn->{channel}, sprintf(
      '%s: %d %s, %d Zeichen, %d Smiley%s',
      $user,
      $row->{words},
      ($row->{words} ne 1)?'Wörter':'Wort',
      $row->{chars},
      $row->{smileys},
      ($row->{smileys} ne 1)?'s':''
    ));
  }
  else {
    $conn->privmsg($conn->{channel}, sprintf(
      'Über %s weiß ich nichts.',
      $user
    ));
  }

  # return success
  return 1;
}

sub count {
  my $self  = shift;
  my ($conn, $event) = @_;

  return 0 unless ($event->{type} eq "public");

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my @parts = split(/\s+/, $message);
  my $counter = {
    words   => 0,
    chars   => 0,
    smileys => 0,
  };

  foreach my $part (@parts) {
    # words
    if ($part =~ /[a-zäöüß]{2,}/i) {
      $counter->{words}++;
      $counter->{chars} += length $part;
      next;
    }
    # smileys
    if ($part =~ /[:;]{1}([-]{1})?[\(\)\\\/PD]{1}/) {
      $counter->{smileys}++;
      next;
    }
  }

  $self->{_sth_get}->execute($sender);
  unless ($self->{_sth_get}->fetchrow_hashref()) {
    $self->{_sth_new}->execute(
      $sender,
      $counter->{words},
      $counter->{chars},
      $counter->{smileys}
    );
  }
  else {
    $self->{_sth_update}->execute(
      $counter->{words},
      $counter->{chars},
      $counter->{smileys},
      $sender
    );
  }

  # don't exit $self-parse
  return 0;
}

1;

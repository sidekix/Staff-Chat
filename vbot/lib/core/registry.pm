package lib::core::registry;

use strict;
use DBI;
use Fcntl ':flock';

use lib::core::log;

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw( );

use constant DATABASE => "data/registry.db";
use constant LOCKFILE => "data/registry.lock";

sub new {
  my $class = shift;

  # connect database
  my $exists    = ( -f DATABASE );
  my $dsn       = "dbi:PgLite:dbname=".DATABASE;

  my $self  = {
    dbh => DBI->connect($dsn),
  };
  bless $self, $class;

  # init database if require
  $self->init_db() unless ($exists);

  # prepare some statements
  $self->{sth_insert} = $self->{dbh}->prepare("INSERT INTO registry (key, value) VALUES (?, ?)");
  $self->{sth_update} = $self->{dbh}->prepare("UPDATE registry SET value=? WHERE key=?");
  $self->{sth_select} = $self->{dbh}->prepare("SELECT * FROM registry WHERE key=?");
  $self->{sth_glob}   = $self->{dbh}->prepare("SELECT * FROM registry WHERE key LIKE ?");
  $self->{sth_delete} = $self->{dbh}->prepare("DELETE FROM registry WHERE key=?");

  return $self;
}

sub set {
  my $self = shift;
  my ($key, $value) = @_;

  # aquire exclusive lock to avoid race condition
  my $fh; unless (open ($fh, ">>".LOCKFILE)) {
    errorlog("unable to write ".LOCKFILE, __FILE__);
    return 0;
  }
  flock($fh, LOCK_EX);

  unless ($self->get($key)) {
    if ($self->{sth_insert}->execute($key, $value)) {
      $self->{sth_insert}->finish();
      return 1;
    }
  }
  else {
    if ($self->{sth_update}->execute($value, $key)) {
      $self->{sth_update}->finish();
      return 1;
    }
  }
  return;
}

sub get {
  my $self = shift;
  my $key = shift;

  $self->{sth_select}->execute($key);
  if (my $r = $self->{sth_select}->fetchrow_hashref()) {
    $self->{sth_select}->finish();
    return $r->{value};
  }
  $self->{sth_select}->finish();
  return;
}

sub glob {
  my $self = shift;
  my $glob = shift;

  $self->{sth_glob}->execute($glob);
  my $results = {};
  while (my $row = $self->{sth_glob}->fetchrow_hashref()) {
    $results->{$row->{key}} = $row->{value};
  }
  $self->{sth_glob}->finish();

  return $results;
}

sub unset {
  my $self = shift;
  my $key = shift;

  # aquire exclusive lock to avoid race condition
  my $fh; unless (open ($fh, ">>".LOCKFILE)) {
    errorlog("unable to write ".LOCKFILE, __FILE__);
    return 0;
  }
  flock($fh, LOCK_EX);

  if ($self->{sth_delete}->execute($key)) {
    $self->{sth_delete}->finish();
    return 1;
  }
  return;
}

sub init_db {
  my $self = shift;

  # aquire exclusive lock to avoid race condition
  my $fh; unless (open ($fh, ">>".LOCKFILE)) {
    errorlog("unable to write ".LOCKFILE, __FILE__);
    return 0;
  }
  flock($fh, LOCK_EX);

  $self->{dbh}->do('
    CREATE TABLE registry (
      key     text NOT NULL,
      value   text
    );');
}

sub DESTROY {
  my $self = shift;

  $self->{sth_insert}->finish() if $self->{sth_insert};
  $self->{sth_update}->finish() if $self->{sth_update};
  $self->{sth_select}->finish() if $self->{sth_select};
  $self->{sth_delete}->finish() if $self->{sth_delete};
  $self->{sth_glob}->finish()   if $self->{sth_glob};
}

1;

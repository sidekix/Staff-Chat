package lib::core::state;

use strict;
use DBI;
use Fcntl ':flock';

use lib::core::log;

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(
  lock
  unlock
  state_set
  state_get
  state_unset
  state_chown
);

use constant DATABASE => "data/state.db";
use constant LOCKFILE => "data/state.lock";

############################################################
# public functions
sub lock {
  my $key = shift || return undef;
  my $lock = lib::core::state->new();
  return $lock->_lock($key)
}

sub unlock {
  my $key = shift || return undef;
  my $lock = lib::core::state->new();
  return $lock->_unlock($key)
}

sub state_set {
  my ($user, $key, $value) = @_;
  my $state = lib::core::state->new();
  return $state->_set($user, $key, $value);
}

sub state_get {
  my ($user, $key) = @_;
  my $state = lib::core::state->new();
  return $state->_get($user, $key);
}

sub state_unset {
  my ($user, $key) = @_;
  my $state = lib::core::state->new();
  return $state->_unset($user, $key);
}

sub state_chown {
  my ($old_nick, $new_nick) = @_;
  my $state = lib::core::state->new();
  return $state->_chown($old_nick, $new_nick);
}

sub state_purge {
  my $nick = shift;
  my $state = lib::core::state->new();
  return $state->_purge($nick);
}

sub reset {
  debuglog('removing state database file', __FILE__);
  unlink DATABASE if ( -f DATABASE );
  my $lock = lib::core::state->new();
}

############################################################
# handler
sub event_nick {
  my $self = shift;
  my ($conn, $event) = @_;

  state_chown($event->{nick}, $event->{args}[0]);
}

sub event_part {
  my $self = shift;
  my ($conn, $event) = @_;

  state_purge($event->{nick});
}

############################################################
# methods
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
  $self->{sth_lock_exists}  = $self->{dbh}->prepare("SELECT 1 FROM lock WHERE key=?");
  $self->{sth_lock}         = $self->{dbh}->prepare("INSERT INTO lock (key) VALUES (?)");
  $self->{sth_unlock}       = $self->{dbh}->prepare("DELETE FROM lock WHERE key=?");

  $self->{sth_insert}       = $self->{dbh}->prepare("INSERT INTO state (nick, key, value) VALUES (?, ?, ?)");
  $self->{sth_update}       = $self->{dbh}->prepare("UPDATE state SET value=? WHERE nick=? AND key=?");
  $self->{sth_select}       = $self->{dbh}->prepare("SELECT * FROM state WHERE nick=? AND key=?");
  $self->{sth_delete}       = $self->{dbh}->prepare("DELETE FROM state WHERE nick=? AND key=?");
  $self->{sth_chown}        = $self->{dbh}->prepare("UPDATE state SET nick=? WHERE nick=?");
  $self->{sth_purge}        = $self->{dbh}->prepare("DELETE FROM state WHERE nick=?");

  return $self;
}

sub _lock {
  my $self = shift;
  my $key  = shift || return undef;

  # aquire exclusive lock to avoid race condition
  my $fh; unless (open ($fh, ">>".LOCKFILE)) {
    errorlog("unable to write ".LOCKFILE, __FILE__);
    return 0;
  }
  flock($fh, LOCK_EX);

  $self->{sth_lock_exists}->execute($key);
  if ($self->{sth_lock_exists}->fetchrow_arrayref()) {
    $self->{sth_lock_exists}->finish();
    return 0;
  }

  #debuglog("locking key '$key'", __FILE__);
  if ($self->{sth_lock}->execute($key)) {
    $self->{sth_lock}->finish();
    return 1;
  }

  errorlog("error locking key '$key'", __FILE__);
  return undef;
}

sub _unlock {
  my $self = shift;
  my $key  = shift || return undef;

  #debuglog("unlocking key '$key'", __FILE__);
  if ($self->{sth_unlock}->execute($key)) {
    $self->{sth_unlock}->finish();
    return 1;
  }

  errorlog("error unlocking key '$key'", __FILE__);
  return undef;
}

sub _set {
  my $self = shift;
  my ($user, $key, $value) = @_;

  # aquire exclusive lock to avoid race condition
  my $fh; unless (open ($fh, ">>".LOCKFILE)) {
    errorlog("unable to write ".LOCKFILE, __FILE__);
    return 0;
  }
  flock($fh, LOCK_EX);

  unless ($self->_get($user, $key)) {
    if ($self->{sth_insert}->execute($user, $key, $value)) {
      $self->{sth_insert}->finish();
      return 1;
    }
  }
  else {
    if ($self->{sth_update}->execute($value, $user, $key)) {
      $self->{sth_update}->finish();
      return 1;
    }
  }
  return;
}

sub _get {
  my $self = shift;
  my ($user, $key) = @_;

  $self->{sth_select}->execute($user, $key);
  if (my $r = $self->{sth_select}->fetchrow_hashref()) {
    $self->{sth_select}->finish();
    return $r->{value};
  }
  return;
}

sub _unset {
  my $self = shift;
  my ($user, $key) = @_;

  if ($self->{sth_delete}->execute($user, $key)) {
    $self->{sth_delete}->finish();
    return 1;
  }
  return;
}

sub _chown {
  my $self = shift;
  my ($old_nick, $new_nick) = @_;

  if ($self->{sth_chown}->execute($new_nick, $old_nick)) {
    $self->{sth_chown}->finish();
    return 1;
  }
  return;
}

sub _purge {
  my $self = shift;
  my $nick = shift;

  if ($self->{sth_purge}->execute($nick)) {
    $self->{sth_purge}->finish();
    return 1;
  }
  return;
}

sub init_db {
  my $self = shift;

  #debuglog("creating lock table", __FILE__);
  $self->{dbh}->do('
    CREATE TABLE lock (
      key     varchar(255) UNIQUE NOT NULL
    );');

  #debuglog("creating state table", __FILE__);
  $self->{dbh}->do('
    CREATE TABLE state (
      nick    varchar(255) NOT NULL,
      key     varchar(255) NOT NULL,
      value   text
    );');
}

sub DESTROY {
  my $self = shift;

  $self->{sth_lock_exists}->finish();
  $self->{sth_lock}->finish();
  $self->{sth_unlock}->finish();

  $self->{sth_insert}->finish();
  $self->{sth_update}->finish();
  $self->{sth_select}->finish();
  $self->{sth_delete}->finish();
  $self->{sth_chown}->finish();
  $self->{sth_purge}->finish();
}

1;

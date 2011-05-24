package lib::core::log;

use strict;
use POSIX;

use lib::config;
use lib::core::registry;

use constant ERRORLOG => 'logs/error.log';

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(
  debuglog
  errorlog
);

sub debuglog {
  my $message = shift || return undef;
  my $file = shift || undef;

  my $logmessage = sprintf(
    "[%s] %s%s",
    strftime('%d/%m/%Y @ %H:%M:%S', localtime(time())),
    $message,
    (defined $file)?" ($file)":""
  );

  my $reg = lib::core::registry->new();
  print "$logmessage\n" if ($reg->get('log_debug'));
}

sub errorlog {
  my $message = shift || return undef;
  my $file = shift || undef;

  my $logmessage = sprintf(
    "[%s] %s%s",
    strftime('%d/%m/%Y @ %H:%M:%S', localtime(time())),
    $message,
    (defined $file)?" ($file)":""
  );

  print "$logmessage\n" if ();

  # write to file
  my $fh;
  open($fh, ">>".ERRORLOG);
  print $fh $logmessage."\n";
  close($fh);
}

1;

package lib::parser::google;

use strict;
use Encode;
use WWW::Mechanize;
use Time::HiRes qw( sleep );

use lib::config;
use lib::core::log;
use lib::core::state;

use constant GOOGLE_CHARSET => 'utf-8';
use constant GOOGLE_URL     => 'http://www.google.de/advanced_search?hl=de';

sub new {
  my $class = shift;

  my $self  = { };
  bless $self, $class;

  return $self;
}

sub parse {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 1 if ($self->google($conn, $event));
  return 0 if ($self->help($conn, $event));

}

sub google {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  return 0 unless ($message =~ /^!(google|suche)\s+((\d*)\s+)?(.+)$/i);
  return 0 unless (lock('google'));
  my $sitesearch = ($1 eq 'suche')?1:0;
  my $display = $3 || 1; $display = 10 if $display > 10;
  my $query = $4;

  FORUM_INDEX_URI =~ m/http:\/\/(www\.)?([^\/]+)/;
  my $domain = $2;

  eval {
    local $SIG{ALRM} = sub {
      errorlog('google query timed out!', __FILE__);
      unlock ('google');
      $conn->privmsg($conn->{channel}, "Google antwortete nicht schnell genug.");
      return 0;
    };
    alarm 25;

    my $mech = WWW::Mechanize->new();
    $mech->get(GOOGLE_URL);
    $mech->submit_form(
      form_name => 'f',
      fields    => {
        as_q          => $query,
        as_sitesearch => ($sitesearch)?$domain:''
      },
      button    => 'btnG'
    );
    alarm 0;

    my @links;
    my $length = 0;
    my $count = 1;
    foreach my $link (@{$mech->links}) {
      if ((@{$link}[5]->{'class'} || '') eq 'l') {
        my $url   = @{$link}[0];
        my $name  = @{$link}[1];
        if (length $name > 30) {
          $name = substr($name, 0, 27);
          $name .= '...';
        }

        push @links, [ $name, $url ];
        $length = length $name if (length $name > $length);

        # display first only
        last if $count++ == $display;
      }
    }

    $count = 1;
    foreach my $link (@links) {
      my $name = $link->[0];
      my $url  = $link->[1];
      if ($count++ == 1) {
        $conn->privmsg($conn->{channel}, sprintf(
          '%'.$length.'s: %s', encode(IRC_CHARSET, $name), encode(IRC_CHARSET, $url)));
      }
      else {
        $conn->notice($sender, sprintf(
          '%'.$length.'s: %s', encode(IRC_CHARSET, $name), encode(IRC_CHARSET, $url)));
      }
      sleep IRC_DELAY;
    }
  };


  # return success
  unlock('google');
  return 1;
}

sub help {
  my $self  = shift;
  my ($conn, $event) = @_;

  my $message = $event->{args}[0];
  my $sender  = $event->{nick};

  my   @text;
  if ($message =~ /^!hilfe\s*$/i) {
    push @text, "!hilfe google    - Besser finden mit ".BOT_NICKNAME;
  }
  elsif ($message =~ /^!hilfe\s+google\b$/i) {
    push @text, "Google-Kommandos:";
    push @text, "  !google [<n>] <Suchmuster> - Sucht die n besten Treffer bei Google";
    push @text, "  !suche  [<n>] <Suchmuster> - wie !google, aber Suche nur im Forum";
  }
  elsif ($message =~ /^!hilfe\s+forum\b$/i) {
    push @text, "  !suche [<n>] <Suchmuster>";
    push @text, "                       - Sucht die n besten Threads im Forum";
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

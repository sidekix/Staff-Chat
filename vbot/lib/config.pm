package lib::config;

use strict;

############################################################
### CONFIG SECTION
############################################################
use constant IRC_SERVER       => 'irc.staff-chat.net';
use constant IRC_PORT         => 6667;
use constant IRC_CHANNEL      => '#news.scn';
use constant IRC_CHARSET      => 'iso-8859-1';
use constant IRC_FLOOD        => 0;
use constant IRC_DELAY        => 0.8;
use constant IRC_CHECK_DELAY  => 60;

use constant BOT_NICKNAME     => 'News';
use constant BOT_REALNAME     => 'News Bot';
use constant BOT_USERNAME     => 'News';
use constant BOT_SETBOTMODE   => 1;
use constant BOT_ADMINS       => { 
  # username   passwd (crypted with salt 'vb')
  'Giotto'  => 'vbBgjY2/7gofs',
};

use constant NICKSERV_NAME    => 'NickServ';
use constant NICKSERV_PASSWD  => 'Reeg4Ein';
use constant NICKSERV_TRIGGER => '/^This nickname is registered and protected/';

use constant FORUM_SHORT      => 'VCF';
use constant FORUM_LONG       => 'Very Cool Forum';
use constant FORUM_RSS_URI    => 'http://www.coolforum.local/vb/external.php?type=rss2&lastpost=1';
use constant FORUM_INDEX_URI  => 'http://www.coolforum.local/vb/index.php';
use constant FORUM_CHARSET    => 'utf-8';
use constant FORUM_LINK_MOD_S => ''; # link modifier search regex (empty means no mofification)
use constant FORUM_LINK_MOD_R => ''; # link modifier replace string

use constant HAL_CONVERSATION => 0;
use constant HAL_HOST         => 'host.megahal.tld';
use constant HAL_PORT         => 9001;

############################################################
### DO NOT EDIT AFTER THIS LINE
############################################################

use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(
  IRC_SERVER
  IRC_PORT
  IRC_CHANNEL
  IRC_CHARSET
  IRC_FLOOD
  IRC_DELAY
  IRC_CHECK_DELAY

  BOT_NICKNAME
  BOT_REALNAME
  BOT_USERNAME
  BOT_SETBOTMODE
  BOT_ADMINS

  NICKSERV_NAME
  NICKSERV_PASSWD
  NICKSERV_TRIGGER

  FORUM_SHORT    
  FORUM_LONG     
  FORUM_RSS_URI  
  FORUM_INDEX_URI
  FORUM_CHARSET  
  FORUM_LINK_MOD_S
  FORUM_LINK_MOD_R

  HAL_CONVERSATION
  HAL_HOST        
  HAL_PORT

);

1;

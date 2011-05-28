; #############################################
; #
; # SCN X-Control 1.0 r133
; # (c) Staff-Chat
; #
; # IRC @ irc.staff-chat.net
; #
; #############################################


; ####################
: # Menu´s #
; ####################
menu * {
  SCN X-Control
  .SCN I-Control: { dialog -m idlerpgcontrol idlerpgcontrol }
  -
}

; #######################
: # I-Control #
; #######################

dialog -l idlerpgcontrol {
  title "IdleRPG Control + Info"
  size -1 -1 267 155
  option dbu
  tab "General", 100, 1 0 266 151
  box "Admin", 3, 4 18 33 80, tab 100
  button "+ Admin", 4, 8 29 25 12, tab 100 flat
  button "Beenden", 5, 8 42 25 12, result tab 100 flat multi
  button "Restart", 6, 8 55 25 12, result tab 100 flat multi
  button "Pause", 7, 8 68 25 12, tab 100 flat multi
  button "Jump", 8, 8 81 25 12, tab 100 flat
  box "Idle Cheat", 9, 4 100 97 21, tab 100
  button "HOG", 10, 7 108 40 10, tab 100 flat
  button "Push", 11, 55 108 40 10, tab 100 flat
  box "Idle User Changes", 12, 38 18 62 80, tab 100
  button "Passwort", 13, 40 30 28 12, tab 100 flat
  button "Charname", 14, 70 30 28 12, tab 100 flat
  button "Class", 15, 40 43 28 12, tab 100 flat
  button "Loeschen", 17, 40 56 28 12, tab 100 flat
  text "Benutzername", 101, 107 21 50 9, tab 100
  edit Keine Daten ..., 102, 160 20 102 10, tab 100 read
  text "Zeit bis zum Levelup", 103, 107 61 50 9, tab 100
  edit "Keine Daten ...", 104, 160 60 102 10, tab 100 read
  text "Level", 105, 107 41 50 9, tab 100
  edit Keine Daten ..., 106, 160 40 102 10, tab 100 read
  text "Klasse", 107, 107 31 50 9, tab 100
  edit "Keine Daten ...", 108, 160 30 102 10, tab 100 read
  text "Gesamte Idlezeit", 109, 107 71 50 9, tab 100
  edit "Keine Daten ...", 110, 160 70 102 10, tab 100 read
  text "Itemstaerke", 111, 107 51 50 9, tab 100
  edit "Keine Daten ...", 112, 160 50 102 10, tab 100 read
  button "Neu Syncronisieren", 113, 107 81 154 9, tab 100 flat
  edit %idle.nick, 202, 142 90 50 10, tab 100
  text "Benutzername", 201, 107 91 33 9, tab 100
  text "Passwort", 203, 107 100 33 9, tab 100
  edit %idle.pass, 204, 142 100 50 10, tab 100 pass
  box "Options", 207, 107 111 155 23, tab 100
  check "Auto Login", 205, 204 90 38 10, tab 100
  button "Login", 206, 193 100 62 10, tab 100 flat
  check "Zeit bis zum naechsten Level in der Titelbar anzeigen ?", 208, 110 119 143 10, tab 100
  edit "Name", 27, 42 72 50 10, tab 100 center
  edit "Option", 28, 42 85 50 11, tab 100 center
  tab "Info", 200
  box "Was ist IdleRPG?", 19, 5 14 162 66, tab 200
  edit "Es ist genau das, wonach es sich anhoert: Ein Rollenspiel, wo schweigen das Beste ist. Je laenger man schweigt, desto weiter kann man aufsteigen, andere Helden bekaempfen, seltene Gegenstaende finden oder auch in Gruppen durch die Welt ziehen. Aber, Ihr muesst nichts machen ausser Schweigen. Es sind keine Klassen oder Namen vorgegeben. Die koennt Ihr bei der Registrierung frei waehlen.", 20, 9 22 154 53, tab 200 multi return center
  box "Starfen", 21, 5 79 162 56, tab 200
  text "PART 200*(1.14^(DEIN_LEVEL))", 22, 8 95 155 9, disable tab 200 center
  text "QUIT 20*(1.14^(DEIN_LEVEL))", 23, 8 123 155 8, disable tab 200 center
  text "LOGOUT 20*(1.14^(DEIN_LEVEL))", 24, 8 114 155 8, disable tab 200 center
  text "KICK 250*(1.14^(DEIN_LEVEL))", 25, 8 86 155 8, disable tab 200 center
  text "MSG/SAY [Laenge]*(1.14^(DEIN_LEVEL))", 26, 8 105 155 8, disable tab 200 center
  button "Schliessen", 1, 132 137 34 12, default flat ok cancel
  edit "IdleRPG v1.0 r113", 2, 210 138 54 10, read center
}

; ###############################
: # I-Control aliases #
; ###############################

alias idlerpgcontrol {
  if ($server) {
    dialog $iif($dialog(idlerpgcontrol),-v,-m) idlerpgcontrol idlerpgcontrol
  }
  else {
    echo -a Error - Du musst mit einem server verbunden sein.
  }
}
alias title.idlerpgcontrol {
  titlebar $iif($calc(%idle.nl - $gmt) >= 0,$duration($calc(%idle.nl - $gmt),1) bis zum Levelup,)
}
alias idlerpgcontrolset {
  if ($2) {
    var %idle.days = $calc($1 * 86400), %idletotal = $remove($2,.,:,;), %idle.std = $calc($mid(%idletotal,1,2) * 60 * 60), %idle.min = $calc($mid(%idletotal,3,2) * 60), %idle.sek = $mid(%idletotal,5,2)
    set %idle.nl $calc($gmt + %idle.days + %idle.std + %idle.min + %idle.sek)
  }
}
alias idlerpgcontroladd {
  if ($2) {
    var %idle.days = $calc($1 * 86400), %idletotal = $remove($2,.,:,;), %idle.std = $calc($mid(%idletotal,1,2) * 60 * 60), %idle.min = $calc($mid(%idletotal,3,2) * 60), %idle.sek = $mid(%idletotal,5,2)
    set %idle.nl $calc(%idle.nl + %idle.days + %idle.std + %idle.min + %idle.sek)
  }
}
alias idlerpgcontrolrem {
  if ($2) {
    var %idle.days = $calc($1 * 86400), %idletotal = $remove($2,.,:,;), %idle.std = $calc($mid(%idletotal,1,2) * 60 * 60), %idle.min = $calc($mid(%idletotal,3,2) * 60), %idle.sek = $mid(%idletotal,5,2)
    set %idle.nl $calc(%idle.nl - %idle.days - %idle.std - %idle.min - %idle.sek)
  }
}
alias idlerpgcontrolds {
  if ($2) {
    var %idle.days = $calc($1 * 86400), %idletotal = $remove($2,.,:,;), %idle.std = $calc($mid(%idletotal,1,2) * 60 * 60), %idle.min = $calc($mid(%idletotal,3,2) * 60), %idle.sek = $mid(%idletotal,5,2)
    set %idle.ti $calc((%idle.days + %idle.std + %idle.min + %idle.sek) - $gmt)
  }
}
alias idle.login {
  if (%idle.nick && %idle.pass && $address(Idle,0)) {
    .msg Idle login %idle.nick %idle.pass
  }
}
alias idle.sync {
  if (%idle.nick && !%idle.sync) {
    idlerpgcontrol
    did -b idlerpgcontrol 107-112
    did -ra idlerpgcontrol 108,110,112 Warte auf Daten ...
    set %idle.sync $calc($gmt + $iif($1,$1,120))
    set %idle.syncx 1
    closemsg Idle
    .msg Idle status %idle.nick
  }
}
alias idlerpgcontrol.init {
  did -ra idlerpgcontrol 102 %idle.nick
  did -ra idlerpgcontrol 104 $iif($me ison #IdleRPG.scn,$iif($calc(%idle.nl - $gmt) >= 0,$duration($calc(%idle.nl - $gmt),1),-),-)
  did -ra idlerpgcontrol 106 $iif(%idle.level,%idle.level,-)
  did - $+ $iif(!%idle.nick || !%idle.pass,ub,e) $+ $iif(%idle.alogin,c,u) idlerpgcontrol 205
  set %idle.nick $did(idlerpgcontrol,202).text
  set %idle.pass $did(idlerpgcontrol,204).text
  if (!$me ison #IdleRPG.scn) {
    did -b idlerpgcontrol 206
  }
  if ($calc(%idle.sync - $gmt) <= 0) {
    unset %idle.sync
  }
  did $iif(%idle.syncx,-b,-e) idlerpgcontrol 107-112
  did $iif(%idle.sync,-rab,-rae) idlerpgcontrol 113 $iif(%idle.sync,Bitte Warten .. $calc(%idle.sync - $gmt),Neu Syncronisieren)
  did -ra idlerpgcontrol 110 $iif(!%idle.syncx,$duration($calc($gmt + %idle.ti)),Warte auf Daten ...)
}
alias kampf {
  if ($1) {
    set %idle.kampf.nick $1
    closemsg Idle
    .msg Idle status $1
    .msg Idle status %idle.nick
    dialog $iif($dialog(idle.kampf),-v,-m) idle.kampf idle.kampf
  }
}

; ###############################
: # I-Control Event´s #
; ###############################

on *:JOIN:#IdleRPG.scn: {
  if (%idle.title) {
    .timerrpgtitle 0 1 title.idlerpgcontrol
    idle.login
  }
  if ($nick == $me && %idle.nick && %idle.pass && %idle.alogin) {
    idle.login
  }
}
on *:PART:#IdleRPG.scn: {
  if ($nick == $me) {
    set %idle.nl -
    .timerrpgtitle off
    titlebar
  }
}
on *:DISCONNECT: {
  set %idle.nl -
  .timerrpgtitle off
  titlebar
}
on *:TEXT:*, the *, has attained level *! Next level in * days, *:#IdleRPG.scn: {
  if ($remove($1,$chr(44)) == %idle.nick) {
    idlerpgcontrolset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
    set %idle.level $remove($gettok($1-,$calc($0 - 7),32),!)
    $tip(idleRPG,idleRPG,You have gained level $remove($gettok($1-,$calc($0 - 7),32),!),idlerpgcontrol)
  }
}
on *:TEXT:Penalty of * days, * added to *'s timer for LOGOUT command.:#IdleRPG.scn: {
  if ($mid($8,1,$calc($len($8) - 2)) == %idle.nick) {
    idlerpgcontroladd $3 $gettok($1-,5,32)
  }
}
on *:TEXT:* has been set upon by a * and gets savagely beaten! * days, * is added to *'s clock.:#IdleRPG.scn: {
  if ($1 == %idle.nick) {
    idlerpgcontroladd $gettok($1-,$calc($0 - 8),32) $gettok($1-,$calc($0 - 6),32)
  }
}
on *:TEXT:* [*/*] has been set upon by a * [*/*] and fights it off! * day, * is removed from *'s clock.:#IdleRPG.scn: {
  if ($mid($calc($0 - 1),1,$calc($len($calc($0 - 1)) - 2)) == %idle.nick) {
    idlerpgcontrolrem $gettok($1-,$calc($0 - 8),32) $gettok($1-,$calc($0 - 6),32)
  }
}
on *:TEXT:*, the level *, is now online from nickname *. Next level in * days, *.:#IdleRPG.scn: {
  if ($remove($1,$chr(44)) == %idle.nick) {
    idlerpgcontrolset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
    set %idle.level $remove($gettok($1-,4,32),$chr(44))
    $tip(idlerpgcontrollogin,idleRPG,You have logged on as %idle.nick $+ !,10,,,idlerpgcontrol)
  }
}
on *:TEXT:* reaches next level in * days, *.:#: {
  if ($1 == %idle.nick) {
    idlerpgcontrolset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
  }
}
on ^*:OPEN:?:*: {
  if ($nick == Idle) {
    if ($mid($1,1,$calc($len($1) - 1)) == %idle.nick) {
      if (%idle.kampf.nick && $dialog(idle.kampf)) {
        set %idle.level $3
        did -rae idle.kampf 5 $3
      }
      else {
        idlerpgcontrol
        set %idle.level $3
        idlerpgcontrolset $gettok($1-,$calc($0 - 9),32) $gettok($1-,$calc($0 - 7),32)
        did -ra idlerpgcontrol 108 $remove($gettok($1-,4- $calc($0 - 13),32),;)
        idlerpgcontrolds $gettok($1-,$calc($0 - 5),32) $remove($gettok($1-,$calc($0 - 3),32),;)
        did -ra idlerpgcontrol 112 $gettok($1-,$0,32)
        did -e idlerpgcontrol 107-112
        did $iif($remove($gettok($1-,$calc($0 - 11),32),;) == Online,-b,-e) idlerpgcontrol 206
        unset %idle.syncx
      }
      halt
    }
    elseif ($mid($1,1,$calc($len($1) - 1)) == %idle.kampf.nick) {
      if ($dialog(idle.kampf)) {
        did -rae idle.kampf 7 $3
        did -e idle.kampf 8
        did -ra idle.kampf 3 $mid($1,1,$calc($len($1) - 1))
      }
      halt
    }
    elseif ($1- == No Such User. && %idle.kampf.nick) {
      did -b idle.kampf 8
      did -ra idle.kampf 3 No such user
      halt
    }
    elseif ($1- isin You are not logged in*) {
      if (!$me ison #IdleRPG.scn) {
        join #IdleRPG.scn
      }
      if (!%idle.alogin) {
        idle.login
      }
    }
    idle.sync
  }
}

; ##############################
: # I-Control $devents #
; ##############################

on 1:dialog:idlerpgcontrol:*:*:{
  ; ############################ Anfang von $devent = init
  if $devent = init {
    join #idlerpg.scn
    idle.login
    idlerpgcontrol.init
    idle.sync
    .timeridlerpgcontrol 0 0 idlerpgcontrol.init
    did $iif(%idle.title,-c,-u) idlerpgcontrol 20
  }
  ; ############################ Ende von $devent = init
  ; ############################ Anfang von $devent = sclick
  elseif $devent = sclick {
    if ($did == 1) {
      idlerpgcontrol.init
      .timeridlerpgcontrol off
      unset %idle.chnick
      unset %idle.choption
      unset %idle.fight.nick
    }
    elseif ($did == 205) {
      set %idle.alogin $did(205).state
    }
    elseif ($did == 206) {
      idle.login
    }
    elseif ($did == 113) {
      idle.sync
    }
    elseif ($did == 208) {
      if ($did(208).state == 0) {
        unset %idle.timewarn
      }
      set %idle.title $did(208).state
      .timerrpgtitle $iif($did(208).state == 1,0 1 title.idlerpgcontrol,off)
      titlebar $iif($did(208).state == 1,$iif($calc(%idle.nl - $gmt) >= 0,$duration($calc(%idle.nl - $gmt),1) bis zum Levelup,),)
    }
    ; ############################ Cheat buttons
    elseif ($did = 10) {
      if ($address(Idle,0)) {
        .msg Idle hog
      }
      else {
        halt
      }
    }
    elseif ($did = 11) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle push %idle.chnick %idle.choption
      }
      else {
        halt
      }
    }
    ; ############################ Cheat Buttons Ende
    ; ############################ Admin Buttons
    elseif ($did = 4) {
      if (%idle.chnick && $address(Idle,0)) {
        .msg Idle mkadmin %idle.chnick
      }
      else {
        halt
      }
    }
    elseif ($did = 5) {
      if ($address(Idle,0)) {
        .msg Idle die
      }
      else {
        halt
      }
    }
    elseif ($did = 6) {
      if ($address(Idle,0)) {
        .msg Idle restart
      }
      else {
        halt
      }
    }
    elseif ($did = 7) {
      if ($address(Idle,0)) {
        .msg Idle pause
      }
      else {
        halt
      }
    }
    elseif ($did = 8) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle jump %idle.chnick $+ : $+ %idle.choption
      }
      else {
        halt
      }
    }
    ; ############################ Admin Buttons Ende
    ; ############################ Change Buttons 
    elseif ($did = 13) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle chpass %idle.chnick %idle.choption
      }
      else {
        halt
      }
    }
    elseif ($did = 14) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle chuser %idle.chnick %idle.choption
      }
      else {
        halt
      }
    }
    elseif ($did = 15) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle chclass %idle.chnick %idle.choption
      }
      else {
        halt
      }
    }
    elseif ($did = 17) {
      if (%idle.chnick && %idle.choption && $address(Idle,0)) {
        .msg Idle del %idle.chnick
      }
      else {
        halt
      }
    }
    ; ############################ Change Buttons Ende
  }
  ; ############################ Ende von $devent = sclick
  ; ############################ Anfang von $devent = edit
  elseif $devent == edit {
    if ($did = 27) {
      if ($did(27).text == $null) {
        unset %idle.chnick
      }
      set %idle.chnick $did(27).text
    }
    if ($did = 28) {
      if ($did(28).text == $null) {
        unset %idle.choption
      }
      set %idle.choption $did(28).text
    }
  }
  ; ############################ Ende von $devent = edit
  ; ############################ Anfang von $devent = close
  elseif $devent == close {
    idlerpgcontrol.init
    .timeridlerpgcontrol off
    unset %idle.chnick
    unset %idle.choption
    unset %idle.fight.nick
  }
  ; ############################ Ende von $devent = close
} 


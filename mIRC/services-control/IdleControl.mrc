# IdleRPG Control 1.0 r94
 

dialog -l idlerpg {
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
  button "Backup", 16, 69 43 28 12, tab 100 flat
  button "Loeschen", 17, 40 56 28 12, tab 100 flat
  button "Register", 18, 69 56 28 12, tab 100 flat
  text "My Username", 101, 107 21 50 9, tab 100
  edit Warte auf Daten ..., 102, 160 20 102 10, tab 100 read
  text "Zeit bis zum Levelup", 103, 107 61 50 9, tab 100
  edit "", 104, 160 60 102 10, tab 100 read
  text "Level", 105, 107 41 50 9, tab 100
  edit Warte auf Daten ..., 106, 160 40 102 10, tab 100 read
  text "Klasse", 107, 107 31 50 9, tab 100
  edit "Warte auf Daten ...", 108, 160 30 102 10, tab 100 read
  text "Gesamte Idlezeit", 109, 107 71 50 9, tab 100
  edit "Warte auf Daten ...", 110, 160 70 102 10, tab 100 read
  text "Itemstaerke", 111, 107 51 50 9, tab 100
  edit "Warte auf Daten ...", 112, 160 50 102 10, tab 100 read
  button "Neu Syncronisieren", 113, 107 81 154 9, tab 100 flat
  edit %idle.me, 202, 142 90 50 10, tab 100
  text "Username", 201, 107 91 33 9, tab 100
  text "Password", 203, 107 100 33 9, tab 100
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
  edit "IdleRPG v1.0 r94", 2, 210 138 54 10, read center
}

## Funktionen

on *:DIALOG:idlerpg:init:*: {
  idlerpg.init
  idle.sync
  .timeridlerpg 0 0 idlerpg.init
  did $iif(%idle.title,-c,-u) idlerpg 208
}
on *:DIALOG:idlerpg:sclick:*: {
  if ($did == 205) {
    set %idle.autol $did(205).state
  }
  if ($did == 206) {
    idle.login
  }
  if ($did == 113) {
    idle.sync
  }
  if ($did == 208) {
    if ($did(208).state == 0) {
      unset %idle.timewarn
    }
    set %idle.title $did(208).state
    .timerrpgtitle $iif($did(208).state == 1,0 1 title.idlerpg,off)
    titlebar $iif($did(208).state == 1,$iif($calc(%idle.nl - $gmt) >= 0,$duration($calc(%idle.nl - $gmt),1) until next level,),)
  }
}
on *:DIALOG:idlerpg:close:*: {
  idlerpg.init
  .timeridlerpg off
}

menu * {
  - 
  SCN S-Control
  .IdleRPG {
    idlerpg
  }
}

alias idlerpg {
  if ($server) {
    dialog $iif($dialog(idlerpg),-v,-m) idlerpg idlerpg
  }
  else {
    echo -a Du bist zu keinem Server verbunden...
  }
} 

on *:JOIN:#idlerpg.scn: {
  if (%idle.title) {
    .timerrpgtitle 0 1 title.idlerpg
  }
  if ($nick == $me && %idle.me && %idle.pass && %idle.autol) {
    idle.login
  }
}
on *:PART:#idlerpg.scn: {
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
on *:TEXT:*, the *, has attained level *! Next level in * days, *:#idlerpg.scn: {
  if ($remove($1,$chr(44)) == %idle.me) {
    idlerpgset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
    set %idle.level $remove($gettok($1-,$calc($0 - 7),32),!)
  }
}
on *:TEXT:Penalty of * days, * added to *'s timer for LOGOUT command.:#idlerpg.scn: {
  if ($mid($8,1,$calc($len($8) - 2)) == %idle.me) {
    idlerpgadd $3 $gettok($1-,5,32)
  }
}
on *:TEXT:* has been set upon by a * and gets savagely beaten! * days, * is added to *'s clock.:#idlerpg.scn: {
  if ($1 == %idle.me) {
    idlerpgadd $gettok($1-,$calc($0 - 8),32) $gettok($1-,$calc($0 - 6),32)
  }
}
on *:TEXT:* [*/*] has been set upon by a * [*/*] and fights it off! * day, * is removed from *'s clock.:#idlerpg.scn: {
  if ($mid($calc($0 - 1),1,$calc($len($calc($0 - 1)) - 2)) == %idle.me) {
    idlerpgrem $gettok($1-,$calc($0 - 8),32) $gettok($1-,$calc($0 - 6),32)
  }
}
on *:TEXT:*, the level *, is now online from nickname *. Next level in * days, *.:#idlerpg.scn: {
  if ($remove($1,$chr(44)) == %idle.me) {
    idlerpgset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
    set %idle.level $remove($gettok($1-,4,32),$chr(44))
  }
}
on *:TEXT:* reaches next level in * days, *.:#idlerpg.scn: {
  if ($1 == %idle.me) {
    idlerpgset $gettok($1-,$calc($0 - 2),32) $gettok($1-,$0,32)
  }
}
on ^*:OPEN:?:*: {
  if ($nick == Idle) {
    if ($mid($1,1,$calc($len($1) - 1)) == %idle.me) {
      if {
        idlerpg
        set %idle.level $3
        idlerpgset $gettok($1-,$calc($0 - 9),32) $gettok($1-,$calc($0 - 7),32)
        did -ra idlerpg 108 $remove($gettok($1-,4- $calc($0 - 13),32),;)
        idlerpgds $gettok($1-,$calc($0 - 5),32) $remove($gettok($1-,$calc($0 - 3),32),;)
        did -ra idlerpg 112 $gettok($1-,$0,32)
        did -e idlerpg 107-112
        did $iif($remove($gettok($1-,$calc($0 - 11),32),;) == Online,-b,-e) idlerpg 206
        unset %idle.syncx
      }
      halt
    }
    elseif ($1- == You are not logged in*) {
      if (!$me ison #idlerpg.scn) {
        join #idlerpg.scn
      }
      if (!%idle.autol) {
        idle.login
      }
    }
    idle.sync
  }
}

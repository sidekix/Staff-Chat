; #############################################
; #
; # SCN X-Control 1.0 r174
; # (c) sidekix @ Staff-Chat
; #
; # IRC @ irc.staff-chat.net
; #
; #############################################

; #######
; # Menus
; #######

menu * {
  SCN X-Control
  .X-Contol
  .-
  .D-Control
  ..Debug
  ...An/Aus: {
    if (!%xcontroldebug) || (%xcontroldebug == off) {
      set %xcontroldebug on
      echo -ta [xcontrol-debug] var gesetzt... AN
      set %xcontroldebugchan $$?="DebugChannel mit '#' angeben..."
    }
    elseif (%xcontroldebug == on) {
      .set %xcontroldebug off
    echo -ta [xcontrol-debug] AUS }
    .unset %xcontroldebugchan
    else { halt }
  }
  ..-
  ..D-Control: { dialog -m scndcontrol scndcontrol }
  -
}

; ###########
; # D-Control
; ###########

dialog -l scndcontrol {
  title "Denora Control"
  size -1 -1 206 182
  option dbu
  button "Schliessen", 1, 154 165 38 12, default ok cancel
  button "Login", 2, 88 10 25 12, flat
  button "Logout", 3, 62 10 25 12, flat
  button "Status", 4, 36 10 25 12, flat
  button "Restart", 5, 10 10 25 12, flat
  button "Reload", 6, 114 10 25 12, flat
  box "Main", 7, 4 1 139 36
  box "Module", 8, 4 63 139 40
  button "Modload", 9, 8 72 30 12, flat
  button "Modunload", 10, 74 72 30 12, flat
  button "Mod List", 11, 41 72 30 12, flat
  button "Mod Info", 12, 107 72 30 12, flat
  box "Shutdown", 13, 145 1 56 30
  button "BEENDEN", 14, 157 12 30 12, flat
  edit "Denora 1.0 r61", 15, 149 147 50 10, disable
  box "Set", 16, 4 38 139 23
  radio "An", 17, 6 45 20 10
  radio "Aus", 18, 28 45 20 10
  button "HTML", 19, 53 44 25 12, flat
  button "SQL", 20, 82 44 25 12, flat
  button "Debug", 21, 112 44 25 12, flat
  edit "Benutzername", 22, 9 24 50 10, limit 15 center
  edit "Passwort", 23, 89 24 50 10, pass limit 15 center
  box "Fantasy", 24, 145 31 56 76
  button "An", 25, 158 40 30 12, flat
  button "Aus", 26, 158 56 30 12, flat
  button "Notice", 27, 158 71 30 12, flat
  box "Chanstats", 28, 4 104 139 74
  button "Add", 29, 7 112 25 10, flat
  button "Del", 30, 33 112 25 10, flat
  button "List", 31, 59 112 25 10, flat
  edit "#Channel", 32, 87 112 46 10, center
  text "SUMUSER uebertraegt alle Statistiken von Benutzer2 zu Benutzer1 UND loescht Benutzer 2", 33, 7 125 125 14, disable center
  button "SumUser", 34, 8 141 25 10, flat
  edit "Benutzer1", 35, 34 142 50 10, limit 15 center
  edit "Benutzer2", 36, 84 142 50 10, limit 15 center
  text "RENAME benennt Benutzer1 in Benutzer2 um", 37, 8 152 126 8, disable
  button "Rename", 38, 8 162 25 10, flat
  edit "Benutzer1", 39, 34 162 50 10, limit 15 center
  edit "Benutzer2", 40, 84 162 50 10, limit 15 center
  box "Debug", 41, 145 108 56 31
  radio "An", 42, 147 115 27 10
  radio "Aus", 43, 170 115 27 10
  edit "#Channel", 44, 151 126 41 10, limit 20 center
  edit "Modulname", 45, 12 87 122 10, center
  edit "#Channel", 46, 150 89 45 10, center
}


; ###########
; # Aliases #
; ###########

alias scndcontrol.login {
  if ((%scndcontrol.nick) && (%scndcontrol.pass) && ($address(denora,0) == *!denora@denora.Staff-Chat.net)) {
    .msg denora login %scndcontrol.nick %scndcontrol.pass
  }
  else {
    echo -ta Da stimmt was nicht ...
  }
}


alias scndcontrol.init {
  did -ra scndcontrol 22 %scndcontrol.nick
  did -ra scndcontrol 23 %scndcontrol.pass
  did -ra scndcontrol 35 %scndcontrol.sumnick1
  did -ra scndcontrol 36 %scndcontrol.sumnick2
  did -ra scndcontrol 39 %scndcontrol.remnick1
  did -ra scndcontrol 40 %scndcontrol.remnick2
  set %scndcontrol.nick $did(scndcontrol,22).text
  set %scndcontrol.pass $did(scndcontrol,23).text
  set %scndcontrol.sumnick1 $did(scndcontrol,35).text
  set %scndcontrol.sumnick2 $did(scndcontrol,36).text
  set %scndcontrol.remnick1 $did(scndcontrol,39).text
  set %scndcontrol.renick2 $did(scndcontrol,40).text
  set %scndcontrol.fantasychan $did(scndcontrol,46).text
}

; ######################
; # D-Control $devents #
; ######################

on 1:dialog:scndcontrol:*:*:{
  ; ############################ Anfang von $devent = init
  if $devent = init {
    if (%xcontroldebug == on) && (!%xcontroldebugchan) {
      echo -ta KEIN Ausgabechannel fuer die Debugmessages gesetzt !!
      timerxclose 1 1 dialog -x scndcontrol scndcontrol
    }
    else {
      msg %xcontroldebugchan [xcontrol-debug] D-Control geoeffnet ...
      scndcontrol.init
      .timerscndcontrol 0 0 scndcontrol.init
      msg %xcontroldebugchan [xcontrol-debug] init.timer gestartet ...
    }
  }
  ; ############################ Ende von $devent = init
  ; ############################ Anfang von $devent = sclick
  elseif $devent = sclick {
    if (%xcontroldebug == on) {
      if ($did isnum 1) {
        if $did = 1 {
          ; --- Schliessen Button
          msg %xcontroldebugchan [xcontrol-debug] Loesche Vars...
          .unset %dcontrolset
          .unset %scndcontrol.nick
          .unset %scndcontrol.pass
          .unset %scndcontrol.sumnick1
          .unset %scndcontrol.sumnick2
          .unset %scndcontrol.remnick1
          .unset %scndcontrol.renick2
          .unset %scndcontrol.fantasychan
          msg %xcontroldebugchan [xcontrol-debug] Schliesse D-Control Dialog
        }
      }
      ; ------- did 2-6
      if ($did isnum 2-6) {
        ; Denora Main 5 Buttons, 2 Textboxen
        msg %xcontroldebugchan [xcontrol-debug] D-Main
        if $did = 2 {
          ; --- D-Login
          msg %xcontroldebugchan [xcontrol-debug] D-Login
          scndcontrol.login
        }
        elseif $did = 3 {
          ; --- D-Logout
          msg %xcontroldebugchan [xcontrol-debug] D-Logout
          .msg denora logout
        }
        elseif $did = 4 {
          ; --- D-Status
          msg %xcontroldebugchan [xcontrol-debug] D-Status
          .msg denora status
        }
        elseif $did = 5 {
          ; --- D-Restart
          msg %xcontroldebugchan [xcontrol-debug] D-Restart
          .msg denora restart
        }
        elseif $did = 6 {
          ; --- D-Reload
          msg %xcontroldebugchan [xcontrol-debug] D-Reload
          .msg denora reload
        }
      }
      elseif ($did isnum 9-12) {
        ; Denora Module 4 Buttons
        msg %xcontroldebugchan [xcontrol-debug] 9-12 Module
        if $did = 9 {
          msg %xcontroldebugchan [xcontrol-debug] Modload
          .msg denora modload %scndcontrol.modload
        }
        elseif $did = 11 {
          msg %xcontroldebugchan [xcontrol-debug] Modlist
          .msg denora modlist
        }
        elseif $did = 10 {
          msg %xcontroldebugchan [xcontrol-debug] Modunload
          .msg denora modunload %scndcontrol.modload
        }
        elseif $did = 12 {
          msg %xcontroldebugchan [xcontrol-debug] Modinfo
          .msg denora modinfo %scndcontrol.modload
        }
      }
      ; ----
      elseif ($did isnum 17-18) {
        ; Denora Set 3 Buttons, 2 Radio Buttons
        msg %xcontroldebugchan [xcontrol-debug] Radio Button
        if $did = 17 {
          ; --- Radio Button AN
          msg %xcontroldebugchan [xcontrol-debug] radio 1 == An
          set %dcontrolset on
        }
        elseif $did = 18 {
          ; --- Radio Button Aus
          msg %xcontroldebugchan [xcontrol-debug] radio 2 == Aus
          set %dcontrolset off
        }
      }
      elseif ($did isnum 19-21) {
        msg %xcontroldebugchan [xcontrol-debug] D-Set
        if $did = 19 {
          if (!%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] Kein Radio Button gewaehlt...
            halt
          }
          elseif (%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] D-Set HTML %dcontrolset
            .msg denora set HTML %dcontrolset
          }
        }
        elseif $did = 20 {
          if (!%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] Kein Radio Button gewaehlt...
            halt
          }
          elseif (%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] D-Set SQL %dcontrolset
            .msg denora set sql %dcontrolset
          }
        }
        elseif $did = 21 {
          if (!%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] Kein Radio Button gewaehlt...
            halt
          }
          elseif (%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] D-Set DEBUG %dcontrolset
            .msg denora set sql %dcontrolset
          }
        }
      }
      ; ------- did 25-27
      elseif ($did isnum 25-27) {
        ; Denora Fantasy 3 Buttons
        msg %xcontroldebugchan [xcontrol-debug] D-Fantasy
        if $did = 25 {
          ; --- D-Fantasy An
          msg %xcontroldebugchan [xcontrol-debug] D-Fantasy An
          .msg denora chanstats set %scndcontrol.fantasychan fantasy on
        }
        elseif $did = 26 {
          ; --- D-Fantasy Aus
          .msg denora chanstats set %scndcontrol.fantasychan fantasy off
          msg %xcontroldebugchan [xcontrol-debug] D-Fantasy Aus
        }
        elseif $did = 27 {
          ; --- D-Fantasy Notice
          .msg denora chanstats set %scndcontrol.fantasychan fantasy notice
          msg %xcontroldebugchan [xcontrol-debug] D-Fantasy Notice
        }
      }
      ; -----------
    }
    else {
      if ($did isnum 1) {
        if $did = 1 {
          ; --- Schliessen Button
          .unset %dcontrolset
        }
      }
      ; ------- did 2-6
      if ($did isnum 2-6) {
        ; Denora Main 5 Buttons, 2 Textboxen
        if $did = 2 {
          ; --- D-Login
          .msg denora login %dcontrolname %dcontrolpass
        }
        if $did = 3 {
          ; --- D-Logout
          .msg denora logout
        }
        if $did = 4 {
          ; --- D-Status
          .msg denora status
        }
        if $did = 5 {
          ; --- D-Restart
          .msg denora restart
        }
        if $did = 6 {
          ; --- D-Reload
          .msg denora reload
        }
      }
      ; -----
      if ($did isnum 17-18) {
        ; Denora Set 3 Buttons, 2 Radio Buttons
        if $did = 17 {
          ; --- Radio Button AN
          set %dcontrolset on
        }
        elseif $did = 18 {
          ; --- Radio Button Aus
          set %dcontrolset off
        }
      }
      elseif ($did isnum 19-21) {
        if $did = 19 {
          if (!%dcontrolset) {
            halt
          }
          elseif (%dcontrolset) {
            .msg denora set HTML %dcontrolset
          }
        }
        if $did = 20 {
          if (!%dcontrolset) {
            halt
          }
          elseif (%dcontrolset) {
            .msg denora set sql %dcontrolset
          }
        }
        if $did = 21 {
          if (!%dcontrolset) {
            halt
          }
          elseif (%dcontrolset) {
            .msg denora set sql %dcontrolset
          }
        }
      }
    }
  }
  ; ############################ Ende von $devent = sclick
  ; ############################ Anfang von $devent = edit
  elseif $devent == edit {
    if ($did = 22) {
      if ($did(22).text == $null) {
        unset %scndcontrol.nick
      }
      else {
        set %scndcontrol.nick $did(22).text
      }
    }
    elseif ($did = 23) {
      if ($did(23).text == $null) {
        unset %scndcontrol.pass
      }
      else {
        set %scndcontrol.pass $did(23).text
      }
    }
    elseif ($did = 35) {
      if ($did(35).text == $null) {
        unset %scndcontrol.sumnick1
      }
      else {
        set %scndcontrol.sumnick1 $did(35).text
      }
    }
    elseif ($did = 36) {
      if ($did(36).text == $null) {
        unset %scndcontrol.sumnick2
      }
      else {
        set %scndcontrol.sumnick2 $did(36).text
      }
    }
    elseif ($did = 39) {
      if ($did(39).text == $null) {
        unset %scndcontrol.remnick1
      }
      else {
        set %scndcontrol.remnick1 $did(39).text
      }
    }
    elseif ($did = 40) {
      if ($did(40).text == $null) {
        unset %scndcontrol.remnick2
      }
      else {
        set %scndcontrol.remnick2 $did(40).text
      }
    }
    elseif ($did = 45) {
      if ($did(45).text == $null) {
        unset %scndcontrol.modload
      }
      else {
        set %scndcontrol.modload $did(45).text
      }
    }
    elseif ($did = 46) {
      if ($did(46).text == $null) {
        unset %scndcontrol.fantasychan
      }
      else {
        set %scndcontrol.fantasychan $did(46).text
      }
    }
  }
  ; ############################ Ende von $devent = edit
  ; ############################ Anfang von $devent = close
  elseif $devent == close {
    msg %xcontroldebugchan [xcontrol-debug] Setze Sum/Re Vars ...
    .set %scndcontrol.nick D-Adminnick
    .set %scndcontrol.pass D-Adminpass
    .set %scndcontrol.sumnick1 Benutzername1
    .set %scndcontrol.sumnick2 Benutzername2
    .set %scndcontrol.remnick1 Benutzername1
    .set %scndcontrol.remnick2 Benutzername2
    msg %xcontroldebugchan [xcontrol-debug] Stoppe init.timer ...
    .timerscndcontrol off
  }
  ; ############################ Ende von $devent = close
}


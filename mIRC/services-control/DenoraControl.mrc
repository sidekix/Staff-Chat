; #############################################
; #
; # SCN X-Control 1.0 r153
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
  size -1 -1 195 179
  option dbu
  button "Schliessen", 1, 2 163 37 12, default ok cancel
  button "Login", 2, 88 10 25 12, flat
  button "Logout", 3, 62 10 25 12, flat
  button "Status", 4, 36 10 25 12, flat
  button "Restart", 5, 10 10 25 12, flat
  button "Reload", 6, 114 10 25 12, flat
  box "Main", 7, 4 1 139 36
  box "Module", 8, 4 63 139 26
  button "Modload", 9, 8 72 30 12, flat
  button "Modunload", 10, 41 72 30 12, flat
  button "Mod List", 11, 74 72 30 12, flat
  button "Mod Info", 12, 107 72 30 12, flat
  box "Shutdown", 13, 145 1 42 30
  button "BEENDEN", 14, 151 12 30 12, flat
  edit "Denora 1.0 r40", 15, 136 165 50 10, disable
  box "Set", 16, 4 38 139 23
  radio "An", 17, 6 45 20 10
  radio "Aus", 18, 28 45 20 10
  button "HTML", 19, 58 44 25 12, flat
  button "SQL", 20, 86 44 25 12, flat
  button "Debug", 21, 114 44 25 12, flat
  edit "Benutzername", 22, 9 24 50 10, limit 15 center
  edit "Passwort", 23, 89 24 50 10, pass limit 15 center
  box "Fantasy", 24, 145 31 42 58
  button "An", 25, 151 40 30 12, flat
  button "Aus", 26, 151 56 30 12, flat
  button "Notice", 27, 151 72 30 12, flat
  box "Chanstats", 28, 4 92 183 66
  button "Add", 29, 8 100 25 10, flat
  button "Del", 30, 34 100 25 10, flat
  button "List", 31, 60 100 25 10, flat
  edit "#Channel", 32, 87 100 50 10, center
  text "SUMUSER uebertraegt alle Statistiken von Benutzer2  zu Benutzer1 UND loescht Benutzer 2", 33, 18 111 157 14, disable center
  button "SumUser", 34, 8 126 25 10, flat
  edit "Benutzer1", 37, 38 126 50 10, limit 15 center
  edit "Benutzer2", 38, 91 126 50 10, limit 15 center
  text "RENAME benennt Benutzer1 in Benutzer2 um", 39, 31 136 136 8, disable
  button "Rename", 35, 8 144 25 10, flat
  edit "Benutzer1", 41, 38 144 50 10, limit 15 center
  edit "Benutzer2", 42, 91 144 50 10, limit 15 center
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
  set %scndcontrol.nick $did(scndcontrol,22).text
  set %scndcontrol.pass $did(scndcontrol,23).text
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
      scndcontrol.init
      .timerscndcontrol 0 0 scndcontrol.init
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
        if $did = 3 {
          ; --- D-Logout
          msg %xcontroldebugchan [xcontrol-debug] D-Logout
          .msg denora logout
        }
        if $did = 4 {
          ; --- D-Status
          msg %xcontroldebugchan [xcontrol-debug] D-Status
          .msg denora status
        }
        if $did = 5 {
          ; --- D-Restart
          msg %xcontroldebugchan [xcontrol-debug] D-Restart
          .msg denora restart
        }
        if $did = 6 {
          ; --- D-Reload
          msg %xcontroldebugchan [xcontrol-debug] D-Reload
          .msg denora reload
        }
      }
      ; ----

      if ($did isnum 17-18) {
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
        if $did = 19  {
          if (!%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] Kein Radio Button gewaehlt...
            halt
          }
          elseif (%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] D-Set HTML %dcontrolset
            .msg denora set HTML %dcontrolset
          }
        }
        if $did = 20  {
          if (!%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] Kein Radio Button gewaehlt...
            halt
          }
          elseif (%dcontrolset) {
            msg %xcontroldebugchan [xcontrol-debug] D-Set SQL %dcontrolset
            .msg denora set sql %dcontrolset
          }
        }
        if $did = 21  {
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
        if $did = 19  {
          if (!%dcontrolset) {
            halt
          }
          elseif (%dcontrolset) {
            .msg denora set HTML %dcontrolset
          }
        }
        if $did = 20  {
          if (!%dcontrolset) {
            halt
          }
          elseif (%dcontrolset) {
            .msg denora set sql %dcontrolset
          }
        }
        if $did = 21  {
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
    if ($did = 23) {
      if ($did(23).text == $null) {
        unset %scndcontrol.pass
      }
      else {
        set %scndcontrol.pass $did(23).text
      }
    }
  }
  ; ############################ Ende von $devent = edit
  ; ############################ Anfang von $devent = close
  elseif $devent == close {
    .timerscndcontrol off
  }
  ; ############################ Ende von $devent = close
}


; #############################################
; #
; # SCN X-Control 1.0 r135
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
    .unset %%xcontroldebugchan
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
  size -1 -1 178 179
  option dbu
  button "Schliessen", 1, 2 163 37 12, default ok cancel
  button "Login", 2, 10 52 30 12, flat
  button "Logout", 3, 10 39 30 12, flat
  button "Status", 4, 10 26 30 12, flat
  button Restart", 5, 10 13 30 12, flat
  button "Reload", 6, 10 65 30 12, flat
  box "Main", 7, 4 3 42 82
  box "Module", 8, 49 3 42 68
  button "Modload", 9, 55 13 30 12, flat
  button "Modunload", 10, 55 26 30 12, flat
  button "Mod List", 11, 55 39 30 12, flat
  button "Mod Info", 12, 55 52 30 12, flat
  box "Shutdown", 13, 49 73 42 30
  button "BEENDEN", 14, 55 84 30 12, flat
  edit "Denora 1.0 r22", 15, 125 165 50 10, disable
  box "Set", 16, 4 87 43 61
  radio "An", 17, 6 95 20 10
  radio "Aus", 18, 25 95 20 10
  button "HTML", 19, 7 106 37 12, flat
  button "SQL", 20, 7 119 37 12, flat
  button "Debug", 21, 7 132 37 12, flat
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
        ; Denora Main 3 Buttons, 2 Radio Buttons
        msg %xcontroldebugchan [xcontrol-debug] D-Main
        if $did = 2 {
          ; --- D-Login
          msg %xcontroldebugchan [xcontrol-debug] D-Login
          .msg denora login %dcontrolname %dcontrolpass
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
      ; ------- did 2-16
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

  }
  ; ############################ Ende von $devent = edit
  ; ############################ Anfang von $devent = close
  elseif $devent == close {

  }
  ; ############################ Ende von $devent = close
}


; #############################################
; #
; # SCN X-Control 1.0 r196
; # (c) sidekix @ Staff-Chat
; #
; # IRC @ irc.staff-chat.net
; #
; #############################################


; ##########
; # Menu´s #
; ##########
menu * {
  SCN X-Control
  .NAASC-Control: { dialog -m scnnaasccontrol scnnaasccontrol }
  -
}

; #################
; # NAASC-Control #
; #################

dialog scnnaasccontrol {
  title "NAASC (X-Control) - Not another Anope Services Control"
  size -1 -1 235 179
  option dbu
  tab "Info", 1, 1 1 231 147
  tab "NickServ", 2
  box "Reg / Drop", 9, 4 16 84 63, tab 2
  button "Reg", 10, 6 25 25 12, tab 2
  edit "EMail", 13, 6 40 78 10, tab 2 center
  edit "Passwort", 14, 6 51 78 10, tab 2 center
  edit "Drop Nick", 15, 6 62 78 10, tab 2 center
  box "Login / Logout", 16, 4 81 84 51, tab 2
  button "Login", 17, 7 90 30 12, tab 2
  button "Logout", 18, 54 90 30 12, tab 2
  edit "Nick", 19, 6 105 78 10, tab 2 center
  box "Set", 21, 94 16 82 76, tab 2
  button "Autoop", 22, 96 23 25 12, tab 2
  button "Display", 23, 122 23 25 12, tab 2
  button "Greet", 26, 122 36 25 12, tab 2
  button "EMail", 25, 96 36 25 12, tab 2
  button "Passwort", 24, 148 23 25 12, tab 2
  button "ICQ", 28, 96 49 25 12, tab 2
  button "Hide", 29, 122 49 25 12, tab 2
  button "Secure", 30, 148 49 25 12, tab 2
  button "Confirm", 11, 32 25 25 12, tab 2
  button "Drop", 12, 59 25 25 12, tab 2
  button "Privat", 27, 148 36 25 12, tab 2
  button "URL", 31, 96 62 25 12, tab 2
  button "Sprache", 32, 122 62 25 12, tab 2
  button "Kill", 33, 148 62 25 12, tab 2
  edit "Passwort", 20, 6 117 78 10, tab 2 center
  edit "Option", 34, 96 77 77 11, tab 2 center
  tab "ChanServ", 3
  tab "MemoServ", 4
  tab "HostServ", 5
  tab "OperServ", 7
  edit "NAASC X-Control v1.0 r13", 6, 159 168 72 10, read
  button "Schliessen", 8, 105 157 37 12, default cancel
}

on 1:dialog:scnnaasccontrol:*:*:{
  if $devent = init {
    msg %xcontroldebugchan [xcontrol-debug] Oeffne NAASC-Control
    halt
  }
  elseif $devent = sclick {
    if ($did isnum 8) {
      if $did = 8 { 
        timerxclose 1 1 dialog -x scnnaasccontrol scnnaasccontrol
        msg %xcontroldebugchan [xcontrol-debug] Schliesse NAASC-Control
        halt
      }
    }
  }
  ; elseif $devent == edit { }
  elseif $devent == close {
    msg %xcontroldebugchan [xcontrol-debug] Schliesse NAASC-Control
    halt
  }
}


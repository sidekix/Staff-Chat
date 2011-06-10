; #############################################
; #
; # SCN X-Control 1.0 r189
; # (c) sidekix @  Staff-Chat
; #
; # IRC @ irc.staff-chat.net
; #
; #############################################


; ####################
; # Menu´s #
; ####################
menu * {
  SCN X-Control
  .NAASC-Control: { dialog -m scnnaasccontrol scnnaasccontrol }
  -
}

; #######################
; # I-Control #
; #######################

dialog scnnaasccontrol {
  title "NAASC (X- Control) - Not another Anope Services Control"
  size -1 -1 213 147
  option dbu
  tab "Info", 1, 1 1 206 127
  tab "NickServ", 2
  tab "ChanServ", 3
  tab "MemoServ", 4
  tab "HostServ", 5
  tab "OperServ", 7
  edit "NAASC X-Control v1.0 r6", 6, 139 135 72 10, read
  button "Schliessen", 8, 100 132 37 12, default
}


on 1:dialog:scnnaasccontrol:*:*:{
  if $devent = init {
    msg %xcontroldebugchan [xcontrol-debug] Oeffne NAASC-Control
  }
  elseif $devent = sclick {
    if ($did isnum 8) {
      if $did = 8 { 
        timerxclose 1 1 dialog -x scnnaasccontrol scnnaasccontrol
        msg %xcontroldebugchan [xcontrol-debug] Schliesse NAASC-Control
      }
    }
  }
  elseif $devent == edit { }
  elseif $devent == close {
    msg %xcontroldebugchan [xcontrol-debug] Schliesse NAASC-Control
  }
  else { echo -ts Unknown devent: $1- }
}


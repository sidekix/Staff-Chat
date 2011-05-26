; #############################################
; #
; # SCN X-Control 1.0 r117
; # (c) Staff-Chat
; #
; # IRC @ irc.staff-chat.net
; #
; #############################################


; ####################
: # Menu´s 
; ####################
menu * {
  SCN X-Control
  .SCN D-Control: { dialog -m scndcontrol scndcontrol }
  -
}

; #######################
: # D-Control 
; #######################

dialog -l scndcontrol {
  title "Denora Control"
  size -1 -1 106 177
  option dbu
  button "Schliessen", 1, 2 163 37 12, default ok cancel
  button "Neustarten", 2, 13 68 30 12, flat
  button "Status", 3, 13 54 30 12, flat
  button "Logout", 4, 13 40 30 12, flat
  button "Login", 5, 13 26 30 12, flat
  box "Main", 6, 7 17 42 84
  box "Module", 7, 52 17 42 84
  button "Modload", 8, 57 26 30 12, flat
  button "Modunload", 9, 57 40 30 12, flat
  button "Mod List", 10, 57 54 30 12, flat
  button "Mod Info", 11, 57 68 30 12, flat
  box "Denora beenden", 12, 7 104 87 45
  button "BEENDEN", 13, 21 116 56 21, flat
  button "Reload", 14, 13 82 30 12, flat
  edit "Denora 1.0 r4", 15, 52 164 50 10, disable
}


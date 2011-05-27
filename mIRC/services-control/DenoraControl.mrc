; #############################################
; #
; # SCN X-Control 1.0 r120
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
  size -1 -1 178 179
  option dbu
  button "Schliessen", 1, 2 163 37 12, default ok cancel
  button "Neustarten", 2, 10 52 30 12, flat
  button "Status", 3, 10 39 30 12, flat
  button "Logout", 4, 10 26 30 12, flat
  button "Login", 5, 10 13 30 12, flat
  box "Main", 6, 4 3 42 82
  box "Module", 7, 49 3 42 68
  button "Modload", 8, 55 13 30 12, flat
  button "Modunload", 9, 55 26 30 12, flat
  button "Mod List", 10, 55 39 30 12, flat
  button "Mod Info", 11, 55 52 30 12, flat
  box "Shutdown", 12, 49 73 42 30
  button "BEENDEN", 13, 55 84 30 12, flat
  button "Reload", 14, 10 65 30 12, flat
  edit "Denora 1.0 r7", 15, 125 165 50 10, disable
  box "Set", 16, 4 87 43 61
  radio "An", 17, 6 95 20 10
  radio "Aus", 18, 25 95 20 10
  button "HTML", 19, 7 106 37 12, flat
  button "SQL", 20, 7 119 37 12, flat
  button "Debug", 21, 7 132 37 12, flat
}


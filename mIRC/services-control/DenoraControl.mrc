; #############################################
; #
; # SCN X-Control 1.0 r124
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
  size -1 -1 159 179
  option dbu
  button "Schliessen", 1, 2 163 37 12, default ok cancel
  button "Neustarten", 2, 10 52 30 12, flat
  button "Status", 3, 10 39 30 12, flat
  button "Logout", 4, 10 26 30 12, flat
  button "Login", 5, 10 13 30 12, flat
  box "Main", 6, 4 3 42 82
  box "Module", 7, 49 3 42 82
  button "Modload", 8, 55 13 30 12, flat
  button "Modunload", 9, 55 30 30 12, flat
  button "Mod List", 10, 55 47 30 12, flat
  button "Mod Info", 11, 55 64 30 12, flat
  box "Shutdown", 12, 93 3 61 30
  button "BEENDEN", 13, 109 14 30 12, flat
  button "Reload", 14, 10 65 30 12, flat
  edit "Denora 1.0 r11", 15, 105 168 50 10, disable
  box "Set", 16, 4 89 87 35
  radio "An", 17, 18 95 20 10
  radio "Aus", 18, 56 95 20 10
  button "HTML", 19, 6 106 27 12, flat
  button "SQL", 20, 34 106 27 12, flat
  button "Debug", 21, 62 106 26 12, flat
  box "Exlude", 22, 4 126 87 36
  button "Add", 23, 7 134 24 12, flat
  button "Del", 24, 35 134 24 12, flat
  button "List", 25, 63 134 24 12, flat
  edit "", 26, 7 149 81 10, limit 13 center
  box "Admin", 27, 94 35 60 104
  button "Add", 28, 107 43 37 12, flat
  button "Del", 29, 107 57 37 12, flat
  button "SetPass", 30, 107 70 37 12, flat
  button "Show", 31, 107 83 37 12, flat
  button "List", 32, 107 96 37 12, flat
  edit "", 33, 98 113 50 10, limit 13 center
  edit "", 34, 98 123 50 10, limit 13 center
}

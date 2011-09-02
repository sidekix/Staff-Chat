; #############################################
; #
; # SCN X-Control 1.0 r209
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
  size -1 -1 272 187
  option dbu
  tab "Info", 1, 1 1 268 149
  tab "NickServ", 2
  box "Reg / Drop", 9, 4 16 84 58, tab 2
  button "Reg", 10, 6 25 25 12, tab 2
  edit "EMail", 13, 6 40 78 10, tab 2 center
  edit "Passwort", 14, 6 51 78 10, tab 2 center
  edit "Confirm Code", 15, 7 61 76 10, tab 2 center
  button "Setzen", 16, 119 130 32 12, tab 2
  box "Login / Logout", 17, 4 76 84 47, tab 2
  button "Login", 18, 8 87 30 12, tab 2
  button "Logout", 19, 54 86 30 12, tab 2
  edit "Nick", 20, 7 100 78 10, tab 2 center
  box "Set", 21, 92 16 84 76, tab 2
  button "Autoop", 22, 96 23 25 12, tab 2
  button "Display", 23, 122 23 25 12, tab 2
  button "Greet", 24, 122 36 25 12, tab 2
  button "EMail", 25, 96 36 25 12, tab 2
  button "Passwort", 26, 148 23 25 12, tab 2
  button "ICQ", 27, 96 49 25 12, tab 2
  button "Hide", 28, 122 49 25 12, tab 2
  button "Secure", 29, 148 49 25 12, tab 2
  button "Confirm", 30, 32 25 25 12, tab 2
  button "Drop", 31, 59 25 25 12, tab 2
  button "Privat", 32, 148 36 25 12, tab 2
  button "URL", 33, 96 62 25 12, tab 2
  button "Sprache", 34, 122 62 25 12, tab 2
  button "Kill", 35, 148 62 25 12, tab 2
  edit "Passwort", 36, 7 110 78 10, tab 2 center
  edit "Option", 37, 96 77 77 11, tab 2 center
  box "Language", 38, 91 94 85 52, tab 2
  radio "DE", 39, 96 100 17 10, tab 2
  radio "EN", 40, 114 100 17 10, tab 2
  radio "EL", 41, 151 118 20 10, tab 2
  radio "NL", 42, 151 100 17 10, tab 2
  radio "PL", 43, 114 109 17 10, tab 2
  radio "FR", 44, 132 100 17 10, tab 2
  radio "IT", 45, 132 109 17 10, tab 2
  radio "CA", 46, 114 118 17 10, tab 2
  radio "ES", 47, 96 109 18 10, tab 2
  radio "RU", 48, 151 109 17 10, tab 2
  radio "TR", 49, 96 118 17 10, tab 2
  radio "PT", 50, 132 118 20 10, tab 2
  radio "HU", 51, 96 127 20 10, tab 2
  box "", 52, 178 17 84 129, tab 2
  button "Access", 53, 181 26 25 12, tab 2
  button "Ajoin", 54, 207 26 25 12, tab 2
  button "Alist", 55, 233 26 25 12, tab 2
  button "Cert", 56, 181 47 25 12, tab 2
  button "Ghost", 57, 207 47 25 12, tab 2
  button "Glist", 58, 233 47 25 12, tab 2
  button "Group", 59, 181 68 25 12, tab 2
  button "Info", 60, 207 68 25 12, tab 2
  button "Recover", 61, 233 68 25 12, tab 2
  button "Release", 62, 181 89 25 12, tab 2
  button "RPass", 63, 207 89 25 12, tab 2
  button "SPass", 64, 233 89 25 12, tab 2
  button "Status", 65, 207 110 25 12, tab 2
  edit "", 66, 183 133 74 10, tab 2
  edit "", 67, 183 123 74 10, tab 2
  tab "ChanServ", 3
  tab "MemoServ", 4
  box "Lesen", 68, 3 15 87 63, tab 4
  button "1", 69, 7 23 15 12, tab 4
  button "2", 70, 23 23 15 12, tab 4
  button "3", 71, 39 23 15 12, tab 4
  button "4", 72, 55 23 15 12, tab 4
  button "5", 73, 71 23 15 12, tab 4
  button "6", 74, 7 36 15 12, tab 4
  button "7", 75, 23 36 15 12, tab 4
  button "8", 76, 39 36 15 12, tab 4
  button "9", 77, 55 36 15 12, tab 4
  button "10", 78, 71 36 15 12, tab 4
  button "11", 79, 7 49 15 12, tab 4
  button "12", 80, 23 49 15 12, tab 4
  button "13", 81, 39 49 15 12, tab 4
  button "14", 82, 55 49 15 12, tab 4
  button "15", 83, 71 49 15 12, tab 4
  button "16", 84, 7 62 15 12, tab 4
  button "17", 85, 23 62 15 12, tab 4
  button "18", 86, 39 62 15 12, tab 4
  button "19", 87, 55 62 15 12, tab 4
  button "20", 88, 71 62 15 12, tab 4
  box "Loeschen", 89, 3 77 87 62, tab 4
  button "1", 90, 7 84 15 12, tab 4
  button "2", 91, 23 84 15 12, tab 4
  button "3", 92, 39 84 15 12, tab 4
  button "4", 93, 55 84 15 12, tab 4
  button "5", 94, 71 84 15 12, tab 4
  button "6", 95, 7 97 15 12, tab 4
  button "7", 96, 23 97 15 12, tab 4
  button "8", 97, 39 97 15 12, tab 4
  button "9", 98, 55 97 15 12, tab 4
  button "10", 99, 71 97 15 12, tab 4
  button "11", 100, 7 110 15 12, tab 4
  button "12", 101, 23 110 15 12, tab 4
  button "13", 102, 39 110 15 12, tab 4
  button "14", 103, 55 110 15 12, tab 4
  button "15", 104, 71 110 15 12, tab 4
  button "16", 105, 7 123 15 12, tab 4
  button "17", 106, 23 123 15 12, tab 4
  button "18", 107, 39 123 15 12, tab 4
  button "19", 108, 55 123 15 12, tab 4
  button "20", 109, 71 123 15 12, tab 4
  box "Set Notify", 110, 91 15 175 28, tab 4
  button "An", 111, 94 24 27 12, tab 4
  button "Logon", 112, 122 24 27 12, tab 4
  button "Neu", 113, 150 24 27 12, tab 4
  button "Mail", 114, 178 24 27 12, tab 4
  button "Keine Mail", 115, 206 24 27 12, tab 4
  button "Aus", 116, 234 24 27 12, tab 4
  tab "HostServ", 5
  tab "Frei", 7
  edit "NAASC X-Control v1.0 r25", 6, 189 152 80 10, read center
  button "Schliessen", 8, 116 167 37 12, default cancel
  edit "Â© sidekix @ irc.Staff-Chat.net", 11, 189 163 80 10, read center
  edit "http://www.Staff-Chat.net", 12, 189 175 80 10, read center
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
  elseif $devent == edit { }
  elseif $devent == close {
    halt
  }
}

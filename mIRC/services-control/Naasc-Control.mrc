; #############################################
; #
; # SCN X-Control 1.0 r202
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
  tab "Info", 1, 1 1 268 157
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
  radio "HU", 67, 96 127 20 10, tab 2
  box "", 51, 178 17 84 129, tab 2
  button "Access", 52, 181 26 25 12, tab 2
  button "Ajoin", 53, 207 26 25 12, tab 2
  button "Alist", 54, 233 26 25 12, tab 2
  button "Cert", 55, 181 47 25 12, tab 2
  button "Ghost", 56, 207 47 25 12, tab 2
  button "Glist", 57, 233 47 25 12, tab 2
  button "Group", 58, 181 68 25 12, tab 2
  button "Info", 59, 207 68 25 12, tab 2
  button "Recover", 60, 233 68 25 12, tab 2
  button "Release", 61, 181 89 25 12, tab 2
  button "RPass", 62, 207 89 25 12, tab 2
  button "SPass", 63, 233 89 25 12, tab 2
  button "Status", 64, 207 110 25 12, tab 2
  edit "", 65, 183 133 74 10, tab 2
  edit "", 66, 183 123 74 10, tab 2
  tab "ChanServ", 3
  tab "MemoServ", 4
  tab "HostServ", 5
  tab "OperServ", 7
  edit "NAASC X-Control v1.0 r19", 6, 159 168 72 10, read
  button "Schliessen", 8, 105 167 37 12, default cancel
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


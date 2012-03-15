dialog ngic_10 {
  title "NextGen IRC Control"
  size -1 -1 217 215
  option dbu
  icon 1, 0 0 217 137,  $mircdirngic\ngic.png, 0
  button "Schliessen", 2, 180 0 37 12, ok cancel
  box "Anope 1.9.x", 3, 2 141 47 24
  button "Anope ", 4, 4 149 40 12
  box "Denora", 5, 1 164 47 22
  button "Denora", 6, 4 171 40 12
  box "IRC Defender", 7, 50 165 42 22
  button "Defender", 8, 56 172 30 12
  box "IdleRPG", 9, 1 186 47 25
  button "IdleRPG", 10, 4 195 40 12
  box "Atheme 7.x", 11, 51 141 41 24
  button "Atheme", 12, 56 149 30 12
  box "Omega", 13, 50 186 42 25
  button "Omega", 14, 56 195 30 12
  box "P10", 15, 178 139 38 73
  button "GNU World", 16, 181 146 32 12
  button "SrvX", 17, 181 160 32 12
}

on 1:dialog:ngic_10:*:*:{
  if $devent = init { halt } 
  elseif $devent = sclick {
    ; ### Anope Control ID 4
    if $did = 4 { dialog -m ngic_anope ngic_anope }
    ; ### Denora Control ID 6
    ; if $did = 6 { dialog -m ngic_denora ngic_denora }
    ; ### IdleRPG Control ID 10
    ; if $did = 10 { dialog -m ngic_idlerpg ngic_idlerpg }
  }
}

dialog ngic_anope {
  title "NGIC - Anope 1.9.x"
  size -1 -1 235 241
  option dbu
  tab "Info", 1, 0 0 233 213
  icon 2, 33 23 169 59, $mircdirngic\ngic-anope.png, 0, tab 1
  text "Dieses Anope 1.9.x Script gehoert zum NGIC (c) sidekix - irc.staff-chat.net #sidekix", 3, 1 214 232 8, center
  button "Schliessen", 4, 96 226 37 12, ok
  tab "NickServ", 5
  tab "ChanServ", 6
  tab "BotServ", 7
  tab "HostServ", 8
  tab "OperServ / Global", 9
}

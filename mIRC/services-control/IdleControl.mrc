# IdleRPG Control 1.0 r94
 

dialog -l idlecontrol {
  title "IdleRPG Control"
  size -1 -1 280 151
  option dbu
  button "Schliessen", 1, 130 136 34 12, default flat ok cancel
  edit "IdleRPG v1.0 r94", 2, 220 139 54 10, read center
  box "Admin", 3, 3 4 33 79
  button "+ Admin", 4, 6 13 25 12, flat
  button "Beenden", 5, 6 26 25 12, result flat multi
  button "Restart", 6, 6 39 25 12, result flat multi
  button "Pause", 7, 6 52 25 12, flat multi
  button "Jump", 8, 6 65 25 12, flat
  box "Cheat", 9, 3 84 97 34
  button "HOG", 10, 10 97 40 12, flat
  button "Push", 11, 53 97 40 12, flat
  box "Changes", 12, 38 4 62 80
  button "Passwort", 13, 40 11 28 12, flat
  button "Charname", 14, 69 11 28 12, flat
  button "Class", 15, 40 24 28 12, flat
  button "Backup", 16, 69 24 28 12, flat
  button "Loeschen", 17, 40 37 28 12, flat
  button "Register", 18, 69 37 28 12, flat
  text "Benutzername", 19, 106 11 55 9, center
  edit Keine Daten ..., 20, 162 10 105 10, read
  text "Zeit bis zum Levelup", 21, 106 41 55 9, center
  edit "Keine Daten ...", 22, 162 40 105 10, read
  text "Level", 23, 106 21 55 9, center
  edit Keine Daten ..., 24, 162 20 105 10, read
  text "Klasse", 25, 106 31 55 9, center
  edit "Keine Daten ...", 26, 162 30 105 10, read
  text "Gesamte Idlezeit", 27, 106 51 55 9, center
  edit "Keine Daten ...", 28, 162 50 105 10, read
  text "Item staerke", 29, 106 61 55 9, center
  edit "Keine Daten ...", 30, 162 60 105 10, read
  button "Neu Syncronisieren", 31, 105 71 162 10, flat
  text "Benutzername", 32, 147 82 45 9
  edit %idle.me, 33, 194 82 70 10
  text "Passwort", 34, 147 92 45 9
  edit %idle.pass, 35, 194 92 70 10, pass
  check "Auto Login", 36, 106 83 38 10
  button "Login", 37, 105 103 162 10, flat
  edit "Username", 38, 40 51 57 10, center
  edit "Option", 39, 40 62 57 11, center
  text "", 40, 29 119 245 10, center
  text "Nachricht:", 41, 3 119 25 10
  box "Live Status", 42, 103 2 171 116
}

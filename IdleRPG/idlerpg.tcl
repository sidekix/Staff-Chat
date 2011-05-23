# Hier die Daten fuer den Login anpassen !!
set irpg(login) "login CHARNAME PASSWORT"

# Idlebot´s nick
set irpg(nick) "Idle"

# Channel 
set irpg(chan) "#IdleRPG.scn"

# Number of minutes to check +v status 
set irpg(timer) 3

# Channel check
bind join - #idleRPG* loginIRPG


#############################################################################
# 
#############################################################################
bind dcc - irpg checkIRPG

proc loginIRPG {nick uhost hand chan} {
	global irpg botnick
	if {$nick == $botnick} {
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
	}
} 

proc checkIRPG {handle idx text} {
	global botnick irpg 
	if {[botonchan $irpg(chan)] && ![isvoice $botnick $irpg(chan)]} { 
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)" 
		putlog "relogging into iRPG"
	} else { 
		putlog "Ich habe voice in $irpg(chan) aber ..."
		puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
	}
}

proc timeCheckIRPG {} {
        global botnick irpg
        if {[botonchan $irpg(chan)] && ![isvoice $botnick $irpg(chan)]} {
                putlog "Kein voice in $irpg(chan)... Sende login..."
                puthelp "PRIVMSG $irpg(nick) :$irpg(login)"
        }
	set irpg(running) [timer $irpg(timer) timeCheckIRPG]
        return 1
}


if {[info exists irpg(running)]} {killtimer $irpg(running)}
set irpg(running) [timer 3 timeCheckIRPG]


putlog "eggdrop idleRPG login"

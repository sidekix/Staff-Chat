# Zeigt IRCops in der Nicklist orange an

raw 352:*: {
  if (* isin $7) { cline 07 $2 $6 | halt }
}

on ^*:join:#:{
  if ($nick == $me) { haltdef | .who # }
  else { haltdef | .who # }
}

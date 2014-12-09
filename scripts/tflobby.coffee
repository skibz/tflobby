lobby = require('../src/lobby.coffee')

# Description:
#   exposes a set of commands for handling team fortress lobbies
#
# Configuration:
#   TFLOBBY_MAPS - a comma separated list of map names.
#   TFLOBBY_POPULAR_MAPS - a comma separated list of the most played maps
#   TFLOBBY_RCON_SERVERNAME - the rcon password to use in rcon commands. replace "SERVERNAME" with any identifier you wish.
#
# Commands:
#   hubot rcon [say|message|msg] <message> on <server> - sends <message> via rcon to <server>. limited to `rcon` roles.
#   hubot rcon [list|the list|roster|players] on <server> - sends the player roster from the previous lobby to <server>. limited to `rcon` roles.
#   hubot rcon [change map|changelevel|map] on <server> to <mapname> - changes the map on <server> to <mapname>. limited to `rcon` roles.
#   hubot [sg|new] <mapname> - creates a new lobby with the map set to <mapname>. limited to `officer` roles.
#   hubot [cg|kill] - cancels a running lobby. limited to `officer` roles.
#   hubot add <me|user> - adds <user> to the lobby. addition of other users is limited to `officer` roles.
#   hubot rem <me|user> - removes <user> from the lobby. removal of other users is limited to `officer` roles.
#   hubot map <mapname> - changes the lobby map to <mapname>. limited to `officer` roles.
#   hubot server <servername> - changes the lobby server to <servername>. limited to `officer` roles.
#   hubot [status|games] - reports the lobby status
#   hubot [previous|last game|lastgame|previous game] - reports the previous lobby status
#   hubot top <maps|players> - reports the daily counter data accumulated for either maps or players
#
# Author:
#   skibz
module.exports = (robot) ->
  
  robot.leave (msg) -> lobby.onLeave(robot, msg)
  
  robot.respond /rcon (say|message|msg) (.*) on (.*)/i, (msg) -> lobby.rconSay(robot, msg)
  
  robot.respond /rcon (list|the list|roster|players) on (.*)/i, (msg) -> lobby.rconRoster(robot, msg)
  
  robot.respond /rcon (change map|changelevel|map) on (.*) to (.*)/i, (msg) -> lobby.rconMap(robot, msg)
  
  robot.respond /(sg|new) (.*)/i, (msg) -> lobby.sg(robot, msg)

  robot.respond /(cg|kill)/i, (msg) -> lobby.cg(robot, msg)
  
  robot.respond /add (me|.*)/i, (msg) -> lobby.add(robot, msg)
  
  robot.respond /rem (me|.*)/i, (msg) -> lobby.rem(robot, msg)
  
  robot.respond /map (.*)/i, (msg) -> lobby.map(robot, msg)
  
  robot.respond /server (.*)/i, (msg) -> lobby.server(robot, msg)
  
  robot.respond /(status|games)/i, (msg) -> lobby.status(robot, msg)
  
  robot.respond /(previous|last game|lastgame|previous game)/i, (msg) -> lobby.previous(robot, msg)
  
  robot.respond /top (maps|players)/i, (msg) -> lobby.top(robot, msg)

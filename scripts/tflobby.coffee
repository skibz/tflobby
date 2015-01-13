# Description:
#   exposes a set of commands for handling team fortress lobbies
#
# Configuration:
#   TFLOBBY_MAPS - a comma separated list of map names.
#   TFLOBBY_POPULAR_MAPS - a comma separated list of the most played maps
#   TFLOBBY_GAME_SERVERS - array of json objects keyed by server data, eg. port, password, host, etc... 
#
# Commands:
#   hubot rcon [say|message|msg] <message> on <server> - sends <message> via rcon to <server>. limited to `rcon` roles.
#   hubot rcon [list|the list|roster|players] on <server> - sends the player roster from the previous lobby to <server>. limited to `rcon` roles.
#   hubot rcon [change map|changelevel|map] on <server> to <mapname> - changes the map on <server> to <mapname>. limited to `rcon` roles.
#   hubot [sg|new] <mapname> - creates a new lobby with the map set to <mapname>. limited to `officer` roles.
#   hubot [cg|kill] - cancels a running lobby. limited to `officer` roles.
#   hubot format <nPlayers> - changes the number of players per side to nPlayers.
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

commands = require('../src/commands.coffee')

module.exports = (robot) ->
  
  robot.leave (msg) -> commands.onLeave(robot, msg)
  
  robot.respond /rcon (say|message|msg) (.*) on (.*)/i, (msg) -> commands.rconSay(robot, msg)
  
  robot.respond /rcon (list|the list|roster|players) on (.*)/i, (msg) -> commands.rconRoster(robot, msg)
  
  robot.respond /rcon (change map|changelevel|map) on (.*) to (.*)/i, (msg) -> commands.rconMap(robot, msg)
  
  robot.respond /(sg|new) (.*)/i, (msg) -> commands.sg(robot, msg)

  robot.respond /(cg|kill)/i, (msg) -> commands.cg(robot, msg)

  robot.respond /format (.*)/i, (msg) -> commands.format(robot, msg)
  
  robot.respond /add (me|.*)/i, (msg) -> commands.add(robot, msg)
  
  robot.respond /rem (me|.*)/i, (msg) -> commands.rem(robot, msg)
  
  robot.respond /map (.*)/i, (msg) -> commands.map(robot, msg)
  
  robot.respond /server (.*)/i, (msg) -> commands.server(robot, msg)
  
  robot.respond /(status|games)/i, (msg) -> commands.status(robot, msg)
  
  robot.respond /(previous|last game|lastgame|previous game)/i, (msg) -> commands.previous(robot, msg)
  
  robot.respond /top (maps|players)/i, (msg) -> commands.top(robot, msg)

# Description:
#   exposes a set of commands for handling team fortress lobbies
#
# Dependencies:
#   simple-rcon
#
# Configuration:
#   HUBOT_AUTH_ADMIN - a comma-separated list of nicknames to set as super-admins
#   TFLOBBY_MAPS - a comma-separated list of map names
#   TFLOBBY_POPULAR_MAPS - a comma-separated list of popular maps
#   TFLOBBY_GAME_SERVERS - objects containing server data keyed by server name in escaped json
#   TFLOBBY_DEFAULT_SERVER - name of default server corresponding to an entry in TFLOBBY_GAME_SERVERS
#
# Commands:
#   hubot rcon [say|message|msg] <message> on <server> - sends <message> via rcon to <server>. limited to `rcon` roles.
#   hubot rcon send [list|the list|roster|players] on <server> - sends the player roster from the previous lobby to <server>. limited to `rcon` roles.
#   hubot rcon [change map|changelevel|map] on <server> to <mapname> - changes the map on <server> to <mapname>. limited to `rcon` roles.
#   hubot [[sg|new]|[[sg|new] <mapname>]|[sg|new] random <gamemode> map] - creates a new lobby with the map set to <mapname>. limited to `officer` roles.
#   hubot [cg|kill] - cancels a running lobby. limited to `officer` roles.
#   hubot format <nPlayers> - changes the number of players per side to nPlayers.
#   hubot [add|add <me|user>] - adds <user> to the lobby. addition of other users is limited to `officer` roles.
#   hubot [rem|rem <me|user>] - removes <user> from the lobby. removal of other users is limited to `officer` roles.
#   hubot [random <gamemode> map|map <mapname>] - changes lobby map to random of game mode or changes the lobby map to <mapname>. limited to `officer` roles.
#   hubot server <servername> - changes the lobby server to <servername>. limited to `officer` roles.
#   hubot [status|games] - reports the lobby status
#   hubot [previous|last game|lastgame|previous game] - reports the previous lobby status
#   hubot top <maps|players> - reports the daily counter data accumulated for either maps or players
#   hubot change <property> to <value> - changes a tflobby bot setting
#
# Author:
#   skibz

{ lifecycle, community, rcon, admin } = require('../src/commands')

module.exports = (robot) ->

  robot.enter (msg) -> lifecycle.onEnter.call(robot, msg)
  robot.leave (msg) -> lifecycle.onLeave.call(robot, msg)

  robot.respond /(add|add (me|.*))/i, (msg) -> lifecycle.add.call(robot, msg)
  robot.respond /(rem|rem (me|.*))/i, (msg) -> lifecycle.rem.call(robot, msg)

  robot.respond /(status|games)/i, (msg) -> community.status.call(robot, msg)
  robot.respond /(previous|lastgame)/i, (msg) -> community.previous.call(robot, msg)
  robot.respond /(top|today) (maps|players)/i, (msg) -> community.top.call(robot, msg)

  robot.respond /rcon (say|message|msg) (.*) on (.*)/i, (msg) -> rcon.rconSay.call(robot, msg)
  robot.respond /rcon send (list|the list|roster|players) on (.*)/i, (msg) -> rcon.rconRoster.call(robot, msg)
  robot.respond /rcon (change map|changelevel|map) on (.*) to (.*)/i, (msg) -> rcon.rconMap.call(robot, msg)

  robot.respond /((sg|new)|(sg|new) (.*)|(sg|new) random (.*) map)/i, (msg) -> admin.sg.call(robot, msg)
  robot.respond /(cg|kill)/i, (msg) -> admin.cg.call(robot, msg)
  robot.respond /format (.*)/i, (msg) -> admin.format.call(robot, msg)
  robot.respond /(random (.*) map|map (.*))/i, (msg) -> admin.map.call(robot, msg)
  robot.respond /server (.*)/i, (msg) -> admin.server.call(robot, msg)
  robot.respond /change (.*) to (.*)/i, (msg) -> admin.change.call(robot, msg)

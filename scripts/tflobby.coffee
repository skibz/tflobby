lobby = require '../src/lobby.coffee'

module.exports = (robot) ->

  robot.leave (msg) ->
    return lobby.onLeave robot, msg

  robot.respond /rcon (say|message|msg) (.*) on (.*)/i, (msg) ->
    return lobby.rconSay robot, msg

  robot.respond /rcon (list|the list|roster|players) on (.*)/i, (msg) ->
    return lobby.rconRoster robot, msg

  robot.respond /rcon (change map|changelevel|map) on (.*) to (.*)/i, (msg) ->
    return lobby.rconMap robot, msg

  robot.respond /(sg|new) (.*)/i, (msg) ->
    return lobby.sg robot, msg

  robot.respond /(cg|kill)/i, (msg) ->
    return lobby.cg robot, msg

  robot.respond /add (me|.*)/i, (msg) ->
    return lobby.add robot, msg

  robot.respond /rem (me|.*)/i, (msg) ->
    return lobby.rem robot, msg

  robot.respond /map (.*)/i, (msg) ->
    return lobby.map robot, msg

  robot.respond /server (.*)/i, (msg) ->
    return lobby.server robot, msg

  robot.respond /(status|games)/i, (msg) ->
    return lobby.status robot, msg

  robot.respond /(recent|recent game|previous|last game|lastgame|previous game)/i, (msg) ->
    return lobby.previous robot, msg

  robot.respond /top (maps|players)/i, (msg) ->
    return lobby.top robot, msg

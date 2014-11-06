lobby = require('../src/lobby')

module.exports = ((robot) ->
  
  robot.leave((msg) -> lobby.onLeave(robot, msg))
  
  robot.respond(/rcon (say|message|msg) (.*) on (.*)/i, (msg) -> lobby.rconSay(robot, msg))
  
  robot.respond(/rcon (list|the list|roster|players) on (.*)/i, (msg) -> lobby.rconRoster(robot, msg))
  
  robot.respond(/rcon (change map|changelevel|map) on (.*) to (.*)/i, (msg) -> lobby.rconMap(robot, msg))
  
  robot.respond(/(sg|new) (.*)/i, (msg) -> lobby.sg(robot, msg))
  
  robot.respond(/(cg|kill)/i, (msg) -> lobby.cg(robot, msg))
  
  robot.respond(/add (me|.*)/i, (msg) -> lobby.add(robot, msg))
  
  robot.respond(/rem (me|.*)/i, (msg) -> lobby.rem(robot, msg))
  
  robot.respond(/map (.*)/i, (msg) -> lobby.map(robot, msg))
  
  robot.respond(/server (.*)/i, (msg) -> lobby.server(robot, msg))
  
  robot.respond(/(status|games)/i, (msg) -> lobby.status(robot, msg))
  
  robot.respond(/(previous|last game|lastgame|previous game)/i, (msg) -> lobby.previous(robot, msg))
  
  robot.respond(/top (maps|players)/i, (msg) -> lobby.top(robot, msg))

)

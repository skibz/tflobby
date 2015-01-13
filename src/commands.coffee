Rcon = require('./rcon.coffee')
Lobby = require('./lobby.coffee')

topToday = (entity) ->

  today = robot.brain.get('today')

  unless today?
    return "i haven't captured any daily data yet..."

  response = '||'

  if not Object.keys(today[entity]).length
    return "i haven't captured any daily #{entity} data yet..."

  response += " #{entity}: #{times} |" for entity, times of today[entity]
  return "#{response}|"

finalising = (robot, msg) ->

  lobby = robot.brain.get('lobby')
  server = robot.brain.get('tflobby.servers')[lobby.server]
  format = lobby.format()

  if lobby?

    players = lobby.names()

    if players.length is format

      return new Rcon(server, (ctx) ->
        ctx.exec('sm_say [ #tfbot ] :: COMING UP ::')
        ctx.exec("sm_say [ #tfbot ] #{lobby.map}")
        ctx.exec("sm_say [ #tfbot ] #{players.join(', ')}")
        ctx.exec('sm_say [ #tfbot ] irc.shadowfire.org')
        ctx.close()

        today = robot.brain.get('today') ? { players: {}, maps: {} }

        if today.maps.hasOwnProperty(lobby.map)
          today.maps[lobby.map]++
        else
          today.maps[lobby.map] = 1

        for player in players
          if today.players.hasOwnProperty(player)
            today.players[player]++
          else
            today.players[player] = 1

        robot.brain.set('today', today)
        robot.brain.set('previous', lobby)

        msg.send(":: steam://connect/#{server.host}:#{server.port}/#{server.password}")
        msg.send(":: no guarantee can be made that your place will still be available if you're late.")
        msg.send(":: pro tip: don\'t be late.")
        msg.send(":: starting a new pickup...")
        created = newLobby(msg.random(popular_maps), 'tfbot', robot.brain.get('tflobby.servers.default'), 6)
        robot.brain.set('lobby', created)
        return msg.send(":: #{created.server} : #{created.map} : 0/#{created.format()} : [  ] ::")
      )

    lobby.finalising = false
    robot.brain.set('lobby', lobby)
    return msg.send("not enough players to begin: #{players.length}/#{format}...")

exports.onLeave = (robot, msg) ->
  lobby = robot.brain.get('lobby')

  return unless lobby?

  user = msg.message.user.id
  players = lobby.names()

  if user in players
    delete lobby.participants[user]
    robot.brain.set('lobby', lobby)
    return msg.send(":: #{lobby.server} : #{lobby.map} : #{players.length}/#{lobby.format()} : [ #{players.join(', ')} ] ::")

exports.rconSay = (robot, msg) ->
  user = msg.message.user.id

  server = servers[msg.match[3].toLowerCase()]

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    if server?.rcon
      return new Rcon(server, (ctx) ->
        ctx.exec("sm_say #{msg.match[2]}", (res) ->
          ctx.close()
          msg.reply("your message was delivered...")
        )
      )

    return msg.reply("the server `#{msg.match[3]}` doesn't exist...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.rconRoster = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    previous = robot.brain.get('previous')
    server = servers[previous.server]

    if previous? and server?.rcon
      return new Rcon(server, (ctx) ->
        ctx.exec("sm_say [ #tfbot ] #{previous.names().join(', ')}", (res) ->
          ctx.close()
          msg.reply("player roster was delivered...")
        )
      )

    return msg.reply("there's no previous game data. creepy...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.rconMap = (robot, msg) ->
  user = msg.message.user.id
  server = servers[msg.match[2].toLowerCase()]
  map = msg.match[3].toLowerCase()

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    if server?

      if server.rcon?

        filtered = maps.filter (map) -> map.indexOf(msg.match[2]) isnt -1

        if filtered.length is 1

          return new Rcon(server, (ctx) ->
            ctx.exec("changelevel #{filtered[0]}", (res) ->
              ctx.close()
              msg.reply("changing map to `#{filtered[0]}`...")
            )
          )

        return msg.reply("which one did you mean? #{filtered.join(', ')}...")

      return msg.reply("an rcon password isn't set for that server...")

    return msg.reply("the server `#{msg.match[2]}` doesn't exist...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.sg = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')
    lobby = robot.brain.get('lobby')

    if lobby?
      return msg.reply("a pickup's already filling...")

    msg.send("starting a new pickup...")

    validMap = msg.match[2] in [popular_maps, maps]
    filtered = maps.filter (map) -> map.indexOf(msg.match[2]) isnt -1

    if filtered.length is 1
      map = filtered[0]
    else
      map = msg.random(popular_maps)

    created = new Lobby(
      map,
      user,
      robot.brain.get('tflobby.servers')[robot.brain.get('tflobby.servers.default')]
    )

    robot.brain.set('lobby', created)

    return msg.send(":: #{created.server} : #{created.map} : 0/#{created.format()} : [  ] ::")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.cg = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')
    lobby = robot.brain.get('lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    robot.brain.set('lobby', null)

    return msg.send("pickup cancelled...")

  return msg.send("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.format = (robot, msg) ->

  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')
    lobby = robot.brain.get('lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    try

      if msg.match[1].indexOf('.') is -1 and msg.match[1].indexOf(',') is -1

        format = parseInt(msg.match[1], 10)

        if format > 0

          if format < 13

            lobby.set('playersPerSide', format)
            robot.brain.set('lobby', lobby)
            return msg.reply("players per side set to `#{format}`...")

          return msg.reply("pickups can have up to twelve players per side...")

        return msg.reply("pickups need at least one player per side...")

      return msg.reply("this command only accepts integer values...")

    catch e

      return msg.reply("this command only accepts integer values...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.add = (robot, msg) ->
  user = msg.message.user.id
  targetingSelf = msg.match[1] is 'me'
  target = if targetingSelf then user else msg.match[1].trim()

  if targetingSelf or (not targetingSelf and robot.auth.hasRole(msg.envelope.user, 'officer'))

    lobby = robot.brain.get('lobby')

    unless lobby?
      lobby = new Lobby(
        msg.random(robot.brain.get('tflobby.maps.popular')),
        user,
        robot.brain.get('tflobby.servers.default')
      )
      robot.brain.set('lobby', lobby)

    players = lobby.names()
    format = lobby.format()

    if players.length < lobby.format()

      if target not in players
        lobby.participants[target] = target
        robot.brain.set('lobby', lobby)
        players = lobby.names()
        msg.send(":: #{lobby.server} : #{lobby.map} : #{players.length}/#{format} : [ #{players.join(', ')} ] ::")
        return unless players.length is format and not lobby.finalising

        return setTimeout(finalising, 60000, robot, msg)

      return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.affirmative'))} #{if msg.match[1] is 'me' then 'you are' else target + ' is'} already added...")

    return msg.reply("the pickup is full...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.rem = (robot, msg) ->
  user = msg.message.user.id
  target = if msg.match[1] is 'me' then user else msg.match[1].trim()

  if target is 'me' or (target isnt 'me' and robot.auth.hasRole(msg.envelope.user, 'officer'))

    lobby = robot.brain.get('lobby')
    players = lobby.names()

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    if target in players
      delete lobby.participants[target]
      robot.brain.set('lobby', lobby)
      format = lobby.format()
      players = lobby.names()
      return msg.send(":: #{lobby.server} : #{lobby.map} : #{players.length}/#{format} : #{players.join(', ')} ::")

    return msg.reply("#{if msg.match[1] is 'me' then 'you\'re not' else target + '\'s not'} added to the pickup...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.map = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')

    lobby = robot.brain.get('lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    filtered = maps.filter (map) -> map.indexOf(msg.match[2]) isnt -1

    if filtered.length is 1
      lobby.set('map', filtered[0])
      robot.brain.set('lobby', lobby)
      return msg.reply("changing map to `#{filtered[0]}`...")
    else
      return msg.reply("which one did you mean? #{filtered.join(', ')}...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.server = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')

    lobby = robot.brain.get('lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    if msg.match[1] in robot.brain.get('tflobby.servers.names')
      lobby.set('server', robot.brain.get('tflobby.servers')[msg.match[1]])
      robot.brain.set('lobby', lobby)
      return msg.reply("server changed to `#{msg.match[1]}`...")

    return msg.reply("unknown server `#{msg.match[1]}`...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.status = (robot, msg) ->

  lobby = robot.brain.get('lobby')

  unless lobby?
    return msg.reply("no pickup to report - create one with !sg or !add")

  players = lobby.names()

  return msg.send(":: #{lobby.server} : #{lobby.map} : #{players.length}/#{lobby.format()} : [ #{players.join(', ')} ] ::")

exports.previous = (robot, msg) ->
  previous = robot.brain.get('previous')

  unless previous?
    return msg.reply("no previous match data...")

  return msg.send(":: started by #{previous.principal} : #{previous.server} : #{previous.map} : [ #{lobby.names().join(', ')} ] : #{new Date(previous.createdAt).toString()} ::")

exports.top = (robot, msg) ->

  if msg.match[1] is 'maps' or msg.match[1] is 'players'
    return msg.reply("#{topToday(msg.match[1])}")
  else
    return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} i don't keep track of those things...")

Rcon = require('../rcon.coffee')
Lobby = require('../lobby.coffee')

finalising = (msg) ->

  return unless (lobby = @brain.get('tflobby.lobby'))?

  server = @brain.get('tflobby.servers.all')[lobby.server.name]
  format = lobby.format()

  if lobby.added() isnt format
    @brain.set('tflobby.lobby', lobby.set('finalising', false))
    return msg.send(":: not enough players to begin: #{players.length}/#{format}...")

  return new Rcon(server, (ctx) ->
    ctx.exec('sm_say [ #tfbot ] :: COMING UP ::')
    ctx.exec("sm_say [ #tfbot ] #{lobby.map}")
    ctx.exec("sm_say [ #tfbot ] #{players.join(', ')}")
    ctx.exec('sm_say [ #tfbot ] irc.shadowfire.org')
    ctx.close()

    players = lobby.names()
    today = @brain.get('tflobby.today') ? { players: {}, maps: {} }

    if today.maps.hasOwnProperty(lobby.map)
      today.maps[lobby.map]++
    else
      today.maps[lobby.map] = 1

    for player in players
      if today.players.hasOwnProperty(player)
        today.players[player]++
      else
        today.players[player] = 1

    @brain.set('tflobby.today', today)
    @brain.set('tflobby.previous', lobby)

    msg.send(":: paging doctors #{players.join(', ')}")
    msg.send(":: steam://connect/#{server.host}:#{server.port}/#{server.password}")
    msg.send(":: no guarantee can be made that your place will still be available if you're late.")
    msg.send(":: pro tip: don\'t be late.")
    msg.send(":: starting a new pickup...")

    created = new Lobby(
      msg.random(@brain.get('tflobby.maps.popular')),
      'tfbot',
      @brain.get('tflobby.servers')[@brain.get('tflobby.servers.default')],
      6
    )

    @brain.set('tflobby.lobby', created)
    return msg.send(":: #{created.server.name} : #{created.map} : 0/#{created.format()} : [  ] ::")
  )

exports.onEnter = (msg) ->

  lobby = @brain.get('tflobby.lobby')
  previous = @brain.get('tflobby.previous')

  if lobby? and previous?
    msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server} : #{previous.map} : [ #{previous.names().join(', ')} ] ::")
    return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{lobby.added()}/#{lobby.format()} : [ #{lobby.names().join(', ')} ] ::")
  else if lobby? and not previous?
    msg.reply(":: no previous pickup data...")
    return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{lobby.added()}/#{lobby.format()} : [ #{lobby.names().join(', ')} ] ::")
  else if not lobby? and previous?
    msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server.name} : #{previous.map} : [ #{previous.names().join(', ')} ] ::")
    return msg.reply(":: no pickup is filling - !add or !sg to create one...")
  else
    msg.reply(":: no previous pickup data...")
    return msg.reply(":: no pickup is filling - !add or !sg to create one...")

exports.onLeave = (msg) ->
  lobby = @brain.get('tflobby.lobby')

  return unless lobby?

  user = msg.message.user.id

  return unless user in players

  lobby.rem(user)
  @brain.set('tflobby.lobby', lobby)
  return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.added()}/#{lobby.format()} : [ #{lobby.names().join(', ')} ] ::")

exports.add = (msg) ->
  user = msg.message.user.id
  targetingSelf = msg.match.length is 1 or msg.match[1] is 'me'
  target = if targetingSelf then user else msg.match[1].trim()

  if targetingSelf or (not targetingSelf and robot.auth.hasRole(msg.envelope.user, 'officer'))

    lobby = @brain.get('tflobby.lobby')

    unless lobby?
      lobby = new Lobby(
        msg.random(@brain.get('tflobby.maps.popular')),
        user,
        @brain.get('tflobby.servers.all')[@brain.get('tflobby.servers.default')]
      )
      @brain.set('tflobby.lobby', lobby)

    players = lobby.names()
    format = lobby.format()

    if lobby.added() < format

      if target not in players
        lobby.add(target)
        @brain.set('tflobby.lobby', lobby)
        added = lobby.added()
        msg.send(":: #{lobby.server.name} : #{lobby.map} : #{added}/#{format} : [ #{lobby.names().join(', ')} ] ::")

        return unless added is format and not lobby.finalising

        return setTimeout(finalising.bind(@), 60000, msg)

      return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.affirmative'))} #{if msg.match[1] is 'me' then 'you are' else target + ' is'} already added...")

    return msg.reply(":: the pickup is full...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.rem = (msg) ->

  user = msg.message.user.id
  targetingSelf = msg.match.length is 1 or msg.match[1] is 'me'
  target = if targetingSelf then user else msg.match[1].trim()

  if targetingSelf or (not targetingSelf and robot.auth.hasRole(msg.envelope.user, 'officer'))

    lobby = @brain.get('tflobby.lobby')
    players = lobby.names()

    unless lobby?
      return msg.reply(':: no pickup filling - create one with !sg or !add...')

    if target in players
      lobby.rem(target)
      @brain.set('tflobby.lobby', lobby)
      return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.added()}/#{lobby.format()} : #{lobby.names().join(', ')} ::")

    return msg.reply(":: #{if msg.match[1] is 'me' then 'you\'re not' else target + '\'s not'} added to the pickup...")

  return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

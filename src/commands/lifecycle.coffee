Rcon = require('../rcon.coffee')
Lobby = require('../lobby.coffee')

finalising = (msg) ->

  return unless (lobby = @brain.get('tflobby.lobby'))?

  server = lobby.server
  players = lobby.players()
  playerNames = players.join(', ')
  totalPlayers = lobby.totalPlayers()
  format = lobby.slots()

  unless lobby.isFull()

    @brain.set('tflobby.lobby', lobby.set('finalising', false))
    return msg.send(":: not enough players to begin: #{totalPlayers}/#{format}...")

  return new Rcon server, ((ctx) ->

    ctx.exec('sm_say [ #tfbot ] :: COMING UP ::')
    ctx.exec("sm_say [ #tfbot ] :: #{lobby.map} ::")
    ctx.exec("sm_say [ #tfbot ] :: #{playerNames} ::")
    ctx.exec('sm_say [ #tfbot ] :: irc.shadowfire.org ::')
    ctx.close()

    msg.send(":: #{playerNames}")
    msg.send(":: pickup is starting on #{server.name}...")
    msg.send(":: steam://connect/#{server.host}:#{server.port}/#{server.password}")
    msg.send(':: creating a new pickup...')

    today = @brain.get('tflobby.today') ? { players: {}, maps: {} }

    for player in players
      if today.players.hasOwnProperty(player)
        today.players[player]++
      else
        today.players[player] = 1

    if today.maps.hasOwnProperty(lobby.map)
      today.maps[lobby.map]++
    else
      today.maps[lobby.map] = 1

    created = new Lobby(
      msg.random(@brain.get('tflobby.maps.popular')),
      'tfbot',
      @brain.get('tflobby.servers.all')[@brain.get('tflobby.servers.default')]
    )

    @brain.set('tflobby.lobby', created)
    @brain.set('tflobby.today', today)
    @brain.set('tflobby.previous', lobby)

    return msg.send(":: #{created.server.name} : #{created.map} : 0/#{created.slots()} : [  ] ::")
  ).bind(@)

module.exports =

  onEnter: (msg) ->

    lobby = @brain.get('tflobby.lobby')
    previous = @brain.get('tflobby.previous')

    if lobby? and previous?
      currentPlayers = Object.keys(lobby.participants)
      msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server.name} : #{previous.map} : [ #{Object.keys(previous.participants).join(', ')} ] ::")
      return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{currentPlayers.length}/#{lobby.playersPerSide * 2} : [ #{currentPlayers.join(', ')} ] ::")
    else if lobby? and not previous?
      players = Object.keys(lobby.participants)
      msg.reply(":: no previous pickup data...")
      return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{players.length}/#{lobby.playersPerSide * 2} : [ #{players.join(', ')} ] ::")
    else if not lobby? and previous?
      msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server.name} : #{previous.map} : [ #{Object.keys(previous.participants).join(', ')} ] ::")
      return msg.reply(":: no pickup is filling - !add or !sg to create one...")
    else
      msg.reply(":: no previous pickup data...")
      return msg.reply(":: no pickup is filling - !add or !sg to create one...")

  onLeave: (msg) ->

    lobby = @brain.get('tflobby.lobby')

    return unless lobby?

    user = msg.message.user.id

    return unless lobby.isAdded(user)

    @brain.set('tflobby.lobby', lobby.rem(user))
    return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")

  add: (msg) ->

    user = msg.message.user.id
    targetingSelf = msg.match[0] is '!add'
    target = if targetingSelf then user else msg.match[1].trim()

    if targetingSelf or (not targetingSelf and @auth.hasRole(msg.envelope.user, 'officer'))

      lobby = @brain.get('tflobby.lobby')

      unless lobby?
        lobby = new Lobby(
          msg.random(@brain.get('tflobby.maps.popular')),
          user,
          @brain.get('tflobby.servers.all')[@brain.get('tflobby.servers.default')]
        )
        @brain.set('tflobby.lobby', lobby)

      unless lobby.isFull()

        unless lobby.isAdded(target)

          @brain.set('tflobby.lobby', lobby.add(target))
          msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")

          if lobby.isFull() and not lobby.finalising
            @brain.set('tflobby.lobby', lobby.set('finalising', true))
            msg.send(":: #{msg.random(@brain.get('tflobby.chat.affirmative'))} pickup full! stick around for just a moment...")
            return setTimeout(finalising.bind(@, msg), 60000)

          return

        return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.affirmative'))} #{if targetingSelf then 'you are' else target + ' is'} already added...")

      return msg.reply(":: the pickup is full...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  rem: (msg) ->

    targetingSelf = msg.match[0] is '!rem'
    target = if targetingSelf then msg.message.user.id else msg.match[1].trim()

    if targetingSelf or (not targetingSelf and @auth.hasRole(msg.envelope.user, 'officer'))

      lobby = @brain.get('tflobby.lobby')
      players = lobby.players()

      unless lobby?
        return msg.reply(':: no pickup filling - create one with !sg or !add...')

      if lobby.isAdded(target)
        @brain.set('tflobby.lobby', lobby.rem(target))
        return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")

      return msg.reply(":: #{if targetingSelf then 'you\'re not' else target + '\'s not'} added to the pickup...")

    return msg.reply("#{msg.random(robot.brain.get('tflobby.chat.mistake'))} you can't do that...")

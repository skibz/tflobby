Rcon = require('../lib/rcon.coffee')
Lobby = require('../lib/lobby.coffee')

finalising = (msg) ->

  return unless (lobby = @brain.get('tflobby.lobby'))?

  server = @brain.get('tflobby.servers.all')[lobby.server.name]
  playerNames = lobby.players().join(', ')
  totalPlayers = lobby.totalPlayers()
  format = lobby.slots()

  unless lobby.isFull()

    @brain.set('tflobby.lobby', lobby.set('finalising', false))
    return msg.send(":: not enough players to begin: #{totalPlayers}/#{format}...")

  return new Rcon server, (err, ctx) ->

    if err
      @brain.set('tflobby.errors.rcon', err)
      msg.send(":: unable to contact the game server due to a rcon error...")
    else
      ctx.exec('sm_say [ #tfbot ] :: COMING UP ::')
      ctx.exec("sm_say [ #tfbot ] :: #{lobby.map} ::")
      ctx.exec("sm_say [ #tfbot ] :: #{playerNames} ::")
      ctx.exec('sm_say [ #tfbot ] :: irc.shadowfire.org ::')
      ctx.close()

    msg.send(":: #{playerNames}")
    msg.send(":: steam://connect/#{server.host}:#{server.port}/#{server.password}")
    msg.send(":: starting a new pickup...")

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

module.exports =

  onEnter: (msg) ->

    lobby = @brain.get('tflobby.lobby')
    previous = @brain.get('tflobby.previous')

    if lobby? and previous?
      msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server} : #{previous.map} : [ #{previous.players().join(', ')} ] ::")
      return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")
    else if lobby? and not previous?
      msg.reply(":: no previous pickup data...")
      return msg.reply(":: current : #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")
    else if not lobby? and previous?
      msg.reply(":: previous : #{new Date(previous.createdAt).toString()} : #{previous.server.name} : #{previous.map} : [ #{previous.players().join(', ')} ] ::")
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
    permitted = targetingSelf or (not targetingSelf and @auth.hasRole(msg.envelope.user, 'officer'))

    if permitted

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

          return unless lobby.isFull() and not lobby.finalising

          return @brain.set(
            'tflobby.lobby.timer',
            setTimeout(finalising.bind(@, msg), 60000)
          )

        return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.affirmative'))} #{if targetingSelf then 'you are' else target + ' is'} already added...")

      return msg.reply(":: the pickup is full...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  rem: (msg) ->

    user = msg.message.user.id
    targetingSelf = msg.match[0] is '!rem'
    target = if targetingSelf then user else msg.match[1].trim()

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

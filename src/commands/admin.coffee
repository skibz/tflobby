Lobby = require('../lobby.coffee')

exports.sg = (msg) ->
  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'officer')
    lobby = @brain.get('tflobby.lobby')

    if lobby?
      return msg.reply(":: a pickup's already filling...")

    popularMaps = @brain.get('tflobby.maps.popular')
    allMaps = @brain.get('tflobby.maps.all')

    newWithoutOptions = msg.match.length is 1
    newWithMap = msg.match.length is 2 and msg.match[0].indexOf('random') is -1
    newWithRandomMap = msg.match.length is 2 and msg.match[0].indexOf('random') isnt -1 and msg.match[1].toLowerCase() in ['cp', 'ctf', 'koth']

    msg.reply(":: starting a new pickup...")

    created = switch true
      when newWithoutOptions
        new Lobby(
          msg.random(popularMaps),
          user,
          @brain.get('tflobby.servers')[@brain.get('tflobby.servers.default')]
        )
      when newWithMap
        validMap = msg.match[2] in [popularMaps, allMaps]
        filtered = maps.filter (map) -> map.indexOf(msg.match[2]) isnt -1

        new Lobby(
          if filtered.length is 1 then filtered[0] else msg.random(popularMaps),
          user,
          @brain.get('tflobby.servers')[@brain.get('tflobby.servers.default')]
        )
      when newWithRandomMap
        new Lobby(
          msg.random(@brain.get("tflobby.maps.#{msg.match[1].toLowerCase()}")),
          user,
          @brain.get('tflobby.servers')[@brain.get('tflobby.servers.default')]
        )
      else
        console.error('i dunno how we got here... ', msg.match)
        null

    @brain.set('tflobby.lobby', created)

    return msg.send(":: #{created.server} : #{created.map} : 0/#{created.format()} : [  ] ::")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.cg = (msg) ->
  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'officer')
    lobby = @brain.get('tflobby.lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    @brain.set('tflobby.lobby', null)

    return msg.send(":: pickup cancelled...")

  return msg.send("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.format = (msg) ->

  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'officer')
    lobby = @brain.get('tflobby.lobby')

    unless lobby?
      return msg.reply(":: no pickup filling - create one with !sg or !add")

    try

      if msg.match[1].indexOf('.') is -1 and msg.match[1].indexOf(',') is -1

        format = parseInt(msg.match[1], 10)

        if format > 0

          if format < 13

            lobby.set('playersPerSide', format)
            @brain.set('tflobby.lobby', lobby)
            return msg.reply(":: players per side set to `#{format}`...")

          return msg.reply(":: pickups can have up to twelve players per side...")

        return msg.reply(":: pickups need at least one player per side...")

      return msg.reply(":: this command only accepts integer values...")

    catch e

      return msg.reply(":: this command only accepts integer values...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.map = (msg) ->
  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'officer')

    lobby = @brain.get('tflobby.lobby')

    unless lobby?
      return msg.reply(":: no pickup filling - create one with !sg or !add")

    if msg.match[0].indexOf('random') isnt -1

      type = msg.match[1].toLowerCase()

      if type in ['cp', 'ctf', 'koth']
        random = msg.random(@brain.get("tflobby.maps.#{type}"))
        lobby.set('map', random)
        return msg.reply(":: changed map to `#{random}`...")

      return msg.reply(":: invalid map type `#{type}`...")

    filtered = maps.filter (map) -> map.indexOf(msg.match[1]) isnt -1

    if filtered.length is 1

      lobby.set('map', filtered[0])
      @brain.set('tflobby.lobby', lobby)
      return msg.reply(":: changing map to `#{filtered[0]}`...")

    return msg.reply(":: which map did you mean? #{filtered.join(', ')}...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.server = (msg) ->
  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'officer')

    lobby = @brain.get('tflobby.lobby')

    unless lobby?
      return msg.reply("no pickup filling - create one with !sg or !add")

    if msg.match[1] in @brain.get('tflobby.servers.names')
      lobby.set('server', @brain.get('tflobby.servers')[msg.match[1]])
      robot.brain.set('tflobby.lobby', lobby)
      return msg.reply(":: server changed to `#{msg.match[1]}`...")

    return msg.reply(":: unknown server `#{msg.match[1]}`...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

exports.change = (msg) ->

  if @auth.hasRole(msg.envelope.user, 'admin')

    switch msg.match[1].toLowerCase()

      when 'default server'

        if msg.match[2] in @brain.get('tflobby.servers.names')

          @brain.set('tflobby.servers.default', msg.match[2])
          return msg.reply(":: changed default server to `#{msg.match[2]}`...")

        return msg.reply(":: invalid server `#{msg.match[2]}`...")

      when 'popular maps'

        popularMaps = msg.match[2].split(',')

        if popularMaps.length > 2

          @brain.set('tflobby.maps.popular', popularMaps)
          return msg.reply(":: changed popular maps to `#{popularMaps.join(', ')}`...")

        return msg.reply(":: you must provide at least three maps...")

      else

        return msg.reply(":: invalid option `#{msg.match[1]}`...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

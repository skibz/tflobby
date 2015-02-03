Lobby = require('../lib/lobby.coffee')

module.exports =

  sg: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'officer')

      user = msg.message.user.id

      if (lobby = @brain.get('tflobby.lobby'))?
        return msg.reply(":: a pickup is already filling...")

      randomPopular = msg.random(@brain.get('tflobby.maps.popular'))
      defaultServer = @brain.get('tflobby.servers.all')[@brain.get('tflobby.servers.default')]

      msg.send(":: starting a new pickup...")

      created = new Lobby(randomPopular, user, defaultServer)
      @brain.set('tflobby.lobby', created)

      return msg.send(":: #{created.server.name} : #{created.map} : 0/#{created.slots()} : [  ] ::")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

  cg: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'officer')

      unless (lobby = @brain.get('tflobby.lobby'))?
        return msg.reply("no pickup filling - create one with !sg or !add")

      @brain.set('tflobby.lobby', null)

      return msg.send(":: pickup cancelled...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  format: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'officer')

      unless (lobby = @brain.get('tflobby.lobby'))?
        return msg.reply(":: no pickup filling - create one with !sg or !add")

      format = parseInt(msg.match[1], 10)

      if format > 0

        if format < 13

          @brain.set('tflobby.lobby', lobby.set('playersPerSide', format))
          return msg.reply(":: players per side set to `#{format}`...")

        return msg.reply(":: pickups can have up to twelve players per side...")

      return msg.reply(":: pickups need at least one player per side...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  map: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'officer')

      unless (lobby = @brain.get('tflobby.lobby'))?
        return msg.reply(":: no pickup filling - create one with !sg or !add")

      if msg.match[1] and msg.match[1].indexOf('random') isnt -1

        type = msg.match[2].toLowerCase()

        if type in ['cp', 'ctf', 'koth']
          random = msg.random(@brain.get("tflobby.maps.#{type}"))
          @brain.set('tflobby.lobby', lobby.set('map', random))
          return msg.reply(":: changed map to `#{random}`...")

        return msg.reply(":: invalid map type `#{type}`...")

      filtered = @brain.get('tflobby.maps.all').filter (map) -> map.indexOf(msg.match[4]) isnt -1

      if filtered.length is 1
        @brain.set('tflobby.lobby', lobby.set('map', filtered[0]))
        return msg.reply(":: changing map to `#{filtered[0]}`...")

      return msg.reply(":: which map did you mean? #{filtered.join(', ')}...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  server: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'officer')

      unless (lobby = @brain.get('tflobby.lobby'))?
        return msg.reply("no pickup filling - create one with !sg or !add")

      server = msg.match[1].toLowerCase()

      if server in @brain.get('tflobby.servers.names')
        @brain.set(
          'tflobby.lobby',
          lobby.set('server', @brain.get('tflobby.servers.all')[server])
        )
        return msg.reply(":: server changed to `#{server}`...")

      return msg.reply(":: unknown server `#{server}`...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

  change: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'admin')

      switch msg.match[1].toLowerCase()

        when 'default server' or 'defaultserver'

          server = msg.match[2].toLowerCase()

          if server in @brain.get('tflobby.servers.names')

            @brain.set('tflobby.servers.default', server)
            return msg.reply(":: changed default server to `#{server}`...")

          return msg.reply(":: invalid server `#{server}`...")

        when 'popular maps' or 'popularmaps'

          popularMaps = msg.match[2].split(',').map (map) -> map.toLowerCase()

          if popularMaps.length > 2

            @brain.set('tflobby.maps.popular', popularMaps)
            return msg.reply(":: changed popular maps to `#{popularMaps.join(', ')}`...")

          return msg.reply(":: you must provide at least three maps...")

        else

          return msg.reply(":: invalid option `#{msg.match[1]}`...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't do that...")

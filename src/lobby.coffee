Rcon = require('./rcon.coffee')

# wip make further passes

responses =
  flava: [
    'you can be my wingman any time.'
    'tfbot is credit to team!'
    'that\'s a negative, ghost-rider, the pattern is full'
  ]
  affirmative: [
    'yes ma\'am!'
    'man, oh man.'
    'work, work.'
    'very well, friend.'
    'yes, mi\'lord.'
    
  ]
  negative: [
    'meh,'
    'oops,'
    'awww,'
    'hmmm,'
    'sigh,'
    'gosh,'
    'bleh,'
    'uh-oh,'
  ]
  mistake: [
    'awkwaaard, but,'
    'oh dear,'
    'i don\'t get it,'
  ]

do ->
  # servers =
  #   is1:
  #     name: 'is1'
  #     host: '196.38.180.26'
  #     port: 27095
  #     tv: ''
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_IS1 ? ''
  #   is2:
  #     name: 'is2'
  #     host: '196.38.180.26'
  #     port: 27115
  #     tv: ''
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_IS2 ? ''
  #   mweb1:
  #     name: 'mweb1'
  #     host: '152.111.192.250'
  #     port: 27015
  #     tv: '152.111.192.250:27030'
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_MWEB1 ? ''
  #   mweb2:
  #     name: 'mweb2'
  #     host: '197.80.200.27'
  #     port: 27015
  #     tv: '197.80.200.27:27030'
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_MWEB2 ? ''
  #   mweb3:
  #     name: 'mweb3'
  #     host: '152.111.192.253'
  #     port: 27017
  #     tv: '152.111.192.253:27030'
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_MWEB3 ? ''
  #   mweb4:
  #     name: 'mweb4'
  #     host: '197.80.200.34'
  #     port: 27015
  #     tv: '197.80.200.34:27030'
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_MWEB4 ? ''
  #   mweb5:
  #     name: 'mweb5',
  #     host: '197.80.200.21'
  #     port: 27015
  #     tv: '197.80.200.21:27030'
  #     password: 'games'
  #     rcon: process.env.TFLOBBY_RCON_MWEB5 ? ''

try
  servers = JSON.parse(process.env['TFLOBBY_GAME_SERVERS'])
catch err
  console.error('[tflobby error] \'TFLOBBY_GAME_SERVERS\' env var parsing failed.')
  console.error('[tflobby error] env var was:', process.env['TFLOBBY_GAME_SERVERS'])
  console.error(err)
  process.exit(1)

serverList = Object.keys servers

if process.env.TFLOBBY_MAPS
  maps = process.env.TFLOBBY_MAPS.split(',')
else
  maps = [
    'cp_gravelpit',
    'cp_badlands',
    'cp_freight_final1',
    'cp_granary',
    'cp_gullywash_final1',
    'cp_process_final',
    'cp_snakewater_final1',
    'cp_well',
    'cp_follower',
    'cp_intermodal_g1f',
    'cp_metalworks_rc5',
    'cp_prolane_v4',
    'cp_sunshine_rc1a',
    'cp_warmfront',
    'ctf_turbine_pro_rc2',
    'koth_pro_viaduct_rc4'
  ]

if process.env.TFLOBBY_POPULAR_MAPS
  popular_maps = process.env.TFLOBBY_POPULAR_MAPS.split(',')
else
  popular_maps = [
    'cp_badlands',
    'cp_granary',
    'cp_gullywash_final1',
    'cp_process_final',
    'cp_snakewater_final1',
  ]

filterMaps = (desired, mapList) ->

  mapList.filter((map) -> map.indexOf(desired) isnt -1)

newLobby = (map, principal, server, format) ->
  lobby =
    createdAt: (new Date()).toJSON()
    map: map
    server: server
    playersPerSide: format
    principal: principal ? 'tfbot'
    participants: {}
    finalising: false

  lobby.names = -> return Object.keys(lobby.participants)
  lobby.format = -> return lobby.format * 2
  @brain.set('lobby', lobby)
  return lobby

finalising = (robot, msg) ->

  lobby = robot.brain.get('lobby')
  server = servers[lobby.server]
  format = lobby.format()
  
  if lobby?
    
    players = lobby.names()

    if players.length is format
      rconReport = ->
        new Rcon(server, (ctx) ->
          ctx.exec('sm_say [ #tfbot ] Pickup is full!')
          ctx.exec("sm_say [ #tfbot ] Map: #{lobby.map}")
          ctx.exec("sm_say [ #tfbot ] Players: #{players.join(' ')}")
          ctx.exec("sm_say [ #tfbot ] irc.shadowfire.org / antino.co.za/tfbot")
          ctx.close()
        )
      ircFinalise = ->
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

        msg.send("steam://connect/#{server.host}:#{server.port}/#{server.password}")
        msg.send("no guarantee can be made that your place will still be available if you're late.")
        msg.send("pro tip: don\'t be late.")
        msg.send("starting a new pickup...")
        created = newLobby(msg.random(popular_maps), 'tfbot', msg.random(serverList[0..2]))
        msg.send("|| #{created.server} | #{created.map} | 0/#{format} | [  ] ||")
      
      do ->
        ircFinalise()
        rconReport()

    lobby.finalising = false
    robot.brain.set('lobby', lobby)
    return msg.send("#{msg.random(responses.mistake)} not enough people: #{players.length}/#{format}. ")

exports.onLeave = (robot, msg) ->
  lobby = robot.brain.get('lobby')
  return unless lobby?

  user = msg.message.user.id
  players = Object.keys(lobby.participants)

  if user in players
    delete lobby.participants[user]
    robot.brain.set('lobby', lobby)
    return msg.send("|| #{lobby.server} | #{lobby.map} | #{players.length}/#{format} | [ #{players.join(', ')} ] ||")

exports.rconSay = (robot, msg) ->
  user = msg.message.user.id

  server = servers[msg.match[3].toLowerCase()]

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    if server?.rcon
      return new Rcon(server, (ctx) ->
        ctx.exec("sm_say #{msg.match[2]}", (res) ->
          ctx.close()
          msg.reply("#{msg.random(responses.affirmative)} your message was delivered...")
        )
      )

    return msg.reply("#{msg.random(responses.mistake)} that's not a valid server...")

  return msg.reply("#{msg.random(responses.mistake)} you can't to do that...")

exports.rconRoster = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    previous = robot.brain.get('previous')
    server = servers[previous.server]

    if previous? and server?.rcon
      return new Rcon(server, (ctx) ->
        ctx.exec("sm_say [ #tfbot ] #{previous.names().join(', ')}", (res) ->
          ctx.close()
          msg.reply("#{msg.random(responses.affirmative)} player roster was delivered...")
        )
      )

    return msg.reply("#{msg.random(responses.mistake)} there's no previous game data. creepy...")

  return msg.reply("#{msg.random(responses.mistake)} you can't to do that...")

exports.rconMap = (robot, msg) ->
  user = msg.message.user.id
  server = servers[msg.match[2].toLowerCase()]
  map = msg.match[3].toLowerCase()

  if robot.auth.hasRole(msg.envelope.user, 'rcon')

    if server?

      if server.rcon?

        filtered = filterMaps(map, maps)

        if filtered.length is 1

          return new Rcon(server, (ctx) ->
            ctx.exec("changelevel #{filtered[0]}", (res) ->
              ctx.close()
              msg.reply("#{msg.random(responses.affirmative)} changing the map...")
            )
          )

        return msg.reply("#{msg.random(responses.mistake)} i'm not familiar with that map...")

      return msg.reply("#{msg.random(responses.mistake)} i dunno the rcon password for that server...")

    return msg.reply("#{msg.random(responses.mistake)} that server don't exist...")

  return msg.reply("#{msg.random(responses.mistake)} you can't to do that...")

exports.sg = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')
    lobby = robot.brain.get('lobby')
    
    if lobby?
      return msg.reply("#{msg.random(responses.mistake)} a pickup's already filling...") 

    msg.send("#{msg.random(responses.affirmative)} starting a new pickup...")

    validMap = msg.match[2] in [ popular_maps, maps ]
    filtered = filterMaps(msg.match[2], maps)

    filtered.length is 1
      map = filtered[0]
    else
      map = msg.random(popular_maps)

    created = newLobby(map, user, robot.brain.get('tflobby.default.server'))
    return msg.send("|| #{created.server} | #{created.map} | #{created.names().length}/#{format} | [  ] ||")

  return msg.send("#{msg.random(responses.mistake)} you can't to do that...")

exports.cg = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')
    lobby = robot.brain.get('lobby')
    return msg.reply("#{msg.random(responses.mistake)} there's no pickup filling...") unless lobby?

    robot.brain.set('lobby', null)

    return msg.send("#{msg.random(responses.negative)}, pickup cancelled...")

  return msg.send("#{msg.random(responses.negative)}, you can't to do that...")

exports.add = (robot, msg) ->
  user = msg.message.user.id
  lobby = robot.brain.get('lobby')
  target = if msg.match[1] is 'me' then user else msg.match[1].trim()

  if target is 'me' or (target isnt 'me' and robot.auth.hasRole(msg.envelope.user, 'officer'))

    unless lobby?
      lobby = newLobby(msg.random(popular_maps), user, msg.random(serverList[0..2]))

    players = lobby.names()

    if players.length < lobby.format()

      if target not in players
        lobby.participants[target] = target
        robot.brain.set('lobby', lobby)
        players = lobby.names()
        format = lobby.format()
        msg.send("|| #{lobby.server} | #{lobby.map} | #{players.length}/#{format} | [ #{players.join(', ')} ] ||")
        return unless players.length is format and not lobby.finalising

        return setTimeout(finalising, 60000, robot, msg)

      return msg.reply("#{if msg.match[1] is 'me' then 'you are' else target + ' is'} already added...")

    return msg.reply("#{msg.random(responses.mistake)} the pickup is already full...")

  return msg.reply("#{msg.random(responses.mistake)} you can't to do that...")

exports.rem = (robot, msg) ->
  user = msg.message.user.id
  target = if msg.match[1] is 'me' then user else msg.match[1].trim()

  if target is 'me' or (target isnt 'me' and robot.auth.hasRole(msg.envelope.user, 'officer'))
    
    lobby = robot.brain.get('lobby')
    players = lobby.names()

    unless lobby?
      return msg.reply("#{msg.random(responses.mistake)} there's no pickup filling...") 

    if target in players
      delete lobby.participants[target]
      robot.brain.set('lobby', lobby)
      format = lobby.format()
      return msg.send("|| #{lobby.server} | #{lobby.map} | #{players.length}/#{format} | [ #{players.join(', ')} ] ||")

    return msg.reply("#{if msg.match[1] is 'me' then 'you\'re not' else target + '\'s not'} added to the pickup...")

  return msg.reply("#{msg.random(responses.mistake)} you can't do that...")

exports.map = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')

    lobby = robot.brain.get('lobby')

    return msg.reply("#{msg.random(responses.mistake)} there's no pickup filling...") unless lobby?

    filtered = filterMaps(msg.match[2], maps)

    return msg.reply "#{msg.random(responses.mistake)} i don't know that map..." unless filtered.length is 1

    lobby.map = filtered[0]
    robot.brain.set('lobby', lobby)
    return msg.reply("#{msg.random(responses.affirmative)} changing map to #{filtered[0]}...")

  return msg.reply("#{msg.random(responses.mistake)} you can't do that...")

exports.server = (robot, msg) ->
  user = msg.message.user.id

  if robot.auth.hasRole(msg.envelope.user, 'officer')

    lobby = robot.brain.get('lobby')
    return msg.reply("#{msg.random(responses.mistake)} there's no pickup filling...") unless lobby?

    if msg.match[1] in serverList
      lobby.server = msg.match[1]
      robot.brain.set('lobby', lobby)
      return msg.reply("#{msg.random(responses.affirmative)} changing the server to #{msg.match[1]}...")

    return msg.reply("#{msg.random(responses.mistake)} i don't know this server: #{msg.match[1]}...")

  return msg.reply("#{msg.random(responses.mistake)} you can't do that...")

exports.status = (robot, msg) ->
  
  lobby = robot.brain.get('lobby')
  
  unless lobby?
    players = lobby.names()
    format = lobby.format()
    return msg.reply("#{msg.random(responses.mistake)} there's no pickup filling...") 
  return msg.send("|| #{lobby.server} | #{lobby.map} | #{players.length}/#{format} | [ #{players.join(', ')} ] ||")

exports.previous = (robot, msg) ->
  previous = robot.brain.get('previous')
  return msg.send("#{msg.random(responses.negative)}, no previous match data...") unless previous?
  return msg.send("|| #{previous.principal} | #{previous.server} | #{previous.map} | [ #{lobby.names().join(', ')} ] | #{new Date(previous.createdAt).toString()} ||")

exports.top = (robot, msg) ->
  
  today = robot.brain.get('today')

  unless today?
    return msg.send("#{msg.random(responses.negative)}, i haven't captured any daily data yet...") 
  
  response = '||'

  if msg.match[1] is 'maps'

    if not Object.keys(today.maps).length
      return msg.send("#{msg.random(responses.negative)}, i haven't captured any daily map data yet...")

    response += " #{map}: #{played} |" for map, played of today.maps

  else

    if not Object.keys(today.players).length
      return msg.send("#{msg.random(responses.negative)}, i haven't captured any daily player data yet...")

    response += " #{player}: #{played} |" for player, played of today.players

  return msg.send("#{response}|")

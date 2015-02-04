fs   = require 'fs'
Path = require 'path'

resurrect = (lobby) ->
  Lobby = require('./src/lobby.coffee')

  return new Lobby(lobby.map, lobby.principal, lobby.server)
    .set('createdAt', lobby.createdAt)
    .set('participants', lobby.participants)
    .set('playersPerSide', lobby.playersPerSide)

module.exports = (robot) ->

  setTimeout((->

    console.log('------------------------------------------')
    console.log('initialising tflobby script')
    console.log('------------------------------------------')

    if (lobby = robot.brain.get('tflobby.lobby'))?
      console.log('attempting to resurrect current!!')
      resurrected = resurrect(lobby)
      console.log(resurrected)
      robot.brain.set('tflobby.lobby', resurrected)

    if (previous = robot.brain.get('tflobby.previous'))?
      console.log('attempting to resurrect previous!!')
      resurrected = resurrect(previous)
      console.log(resurrected)
      robot.brain.set('tflobby.previous', resurrected)

    # chat.flava
    robot.brain.set(
      'tflobby.chat.flava',
      [
        'you can be my wingman any time.',
        'that\'s a negative, ghost-rider, the pattern is full.'
      ]
    )

    # chat.affirmative
    robot.brain.set(
      'tflobby.chat.affirmative',
      [
        'yeah,',
        'man,',
        'baby,'
      ]
    )

    # chat.mistake
    robot.brain.set(
      'tflobby.chat.mistake',
      [
        'um,',
        'oops,',
        'hmmm,',
        'gosh,'
      ]
    )

    try
      servers = JSON.parse(process.env.TFLOBBY_GAME_SERVERS)
    catch err
      console.error('[tflobby error]', err)
      console.error(
        '[tflobby error] TFLOBBY_GAME_SERVERS',
        process.env.TFLOBBY_GAME_SERVERS
      )
      process.exit(1)

    defaultServer = process.env.TFLOBBY_DEFAULT_SERVER

    if not defaultServer
      console.error(
        '[tflobby error] TFLOBBY_DEFAULT_SERVER',
        process.env.TFLOBBY_DEFAULT_SERVER
      )
      process.exit(1)

    # default maps
    maps = [
      'cp_gravelpit',
      'cp_badlands',
      'cp_freight_final1',
      'cp_granary',
      'cp_gullywash_final1',
      'cp_process_final',
      'cp_snakewater_final1',
      'cp_well',
      'arena_badlands',
      'arena_granary',
      'arena_lumberyard',
      'arena_nucleus',
      'arena_offblast_final',
      'arena_ravine',
      'arena_sawmill',
      'arena_watchtower',
      'arena_well'
    ]

    # default popular maps
    popularMaps = [
      'cp_badlands',
      'cp_granary',
      'cp_gullywash_final1',
      'cp_process_final',
      'cp_snakewater_final1'
    ]

    if process.env.TFLOBBY_MAPS
      maps = process.env.TFLOBBY_MAPS.split(',')

    if process.env.TFLOBBY_POPULAR_MAPS
      popularMaps = process.env.TFLOBBY_POPULAR_MAPS.split(',')

    if not (maps and popularMaps)
      console.error('[tflobby warning] no entries found for TFLOBBY_MAPS or TFLOBBY_POPULAR_MAPS')
      console.error('[tflobby warning] defaulting to built-in team fortress maps...')

    mapsByMode = {}

    for map in maps
      mode = map.split('_')[0]
      mapsByMode[mode] = [] unless mapsByMode[mode]?
      mapsByMode[mode].push(map)

    robot.brain.set('tflobby.maps.all', maps)
    robot.brain.set("tflobby.maps.#{mode}", maps) for mode, maps of mapsByMode
    robot.brain.set('tflobby.maps.popular', popularMaps)
    robot.brain.set('tflobby.servers.all', servers)
    robot.brain.set('tflobby.servers.names', Object.keys(servers))
    robot.brain.set('tflobby.servers.default', defaultServer)

    path = Path.resolve(__dirname, 'src')

    fs.exists path, (exists) ->

      unless exists
        console.error("#{path} don't exist")
        process.exit(1)

      robot.loadFile(path, 'index.coffee')
      robot.parseHelp(Path.join(path, 'index.coffee'))
  ).bind(@), 5000)

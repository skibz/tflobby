fs   = require 'fs'
Path = require 'path'

module.exports = (robot) ->

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
    console.error('[tflobby error] TFLOBBY_GAME_SERVERS', process.env.TFLOBBY_GAME_SERVERS)
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
  ]

  # default popular maps
  popularMaps = [
    'cp_badlands',
    'cp_granary',
    'cp_gullywash_final1',
    'cp_process_final',
    'cp_snakewater_final1'
  ]

  maps = process.env.TFLOBBY_MAPS.split(',') if process.env.TFLOBBY_MAPS
  popularMaps = process.env.TFLOBBY_POPULAR_MAPS.split(',') if process.env.TFLOBBY_POPULAR_MAPS

  if not maps and popularMaps
    console.error('[tflobby error] provide entries for TFLOBBY_MAPS and TFLOBBY_POPULAR_MAPS')
    process.exit(1)

  mapsByMode = {}

  for map in maps
    mode = map.split('_')[0]
    mapsByMode[mode] = [] unless mapsByMode[mode]?
    mapsByMode[mode].push(map)

  robot.brain.set('tflobby.maps.all', maps)
  robot.brain.set("tflobby.maps.#{mode}", maps) for mode, maps of mapsByMode
  robot.brain.set('tflobby.maps.popular', popularMaps)
  robot.brain.set('tflobby.servers', servers)
  robot.brain.set('tflobby.servers.names', Object.keys(servers))
  robot.brain.set('tflobby.servers.default', process.env.TFLOBBY_DEFAULT_SERVER)

  path = Path.resolve(__dirname, 'scripts')

  fs.exists(
    path,
    (exists) ->
      if exists
        for file in fs.readdirSync(path)
          robot.loadFile(path, file)
          robot.parseHelp(Path.join(path, file))
  )

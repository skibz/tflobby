
topToday = (metric) ->

  unless (today = @brain.get('tflobby.today'))?
    @brain.set(
      'tflobby.today',
      {
        players: {},
        maps: {}
      }
    )
    return ':: i haven\'t captured any daily data yet...'

  response = '::'

  unless Object.keys(today[metric]).length
    return "i haven't captured any daily #{metric} data yet..."

  response += " #{thing} (#{times}) :" for thing, times of today[metric]
  return "#{response}:"

module.exports =

  status: (msg) ->
    console.log('debug------------------------------')
    console.dir(msg.match)
    console.dir(msg.message)
    console.dir(msg.envelope)
    unless (lobby = @brain.get('tflobby.lobby'))?
      return msg.reply(":: no pickup to report - create one with !sg or !add")

    return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.totalPlayers()}/#{lobby.slots()} : [ #{lobby.players().join(', ')} ] ::")

  previous: (msg) ->
    console.log('debug------------------------------')
    console.dir(msg.match)
    console.dir(msg.message)
    console.dir(msg.envelope)
    unless (previous = @brain.get('tflobby.previous'))?
      return msg.reply(":: no previous match data...")

    return msg.send(":: started by #{previous.principal} : #{previous.server.name} : #{previous.map} : [ #{previous.players().join(', ')} ] : #{new Date(previous.createdAt).toString()} ::")

  top: (msg) ->
    console.log('debug------------------------------')
    console.dir(msg.match)
    console.dir(msg.message)
    console.dir(msg.envelope)
    if msg.match[1] in ['maps', 'players']

      return msg.reply(topToday.call(@, msg.match[1]))

    return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.mistake'))} i don't keep track of those things...")

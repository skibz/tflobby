topToday = (entity) ->

  unless (today = @brain.get('tflobby.today'))?
    @brain.set('tflobby.today', {players: {}, maps: {}})
    return 'i haven\'t captured any daily data yet...'

  response = '||'

  unless Object.keys(today[entity]).length
    return "i haven't captured any daily #{entity} data yet..."

  response += " #{entity}: #{times} |" for entity, times of today[entity]
  return "#{response}|"

exports.status = (msg) ->

  unless (lobby = @brain.get('tflobby.lobby'))?
    return msg.reply(":: no pickup to report - create one with !sg or !add")

  return msg.send(":: #{lobby.server.name} : #{lobby.map} : #{lobby.added()}/#{lobby.format()} : [ #{lobby.players().join(', ')} ] ::")

exports.previous = (msg) ->

  unless (previous = @brain.get('tflobby.previous'))?
    return msg.reply(":: no previous match data...")

  return msg.send(":: started by #{previous.principal} : #{previous.server.name} : #{previous.map} : [ #{previous.names().join(', ')} ] : #{new Date(previous.createdAt).toString()} ::")

exports.top = (msg) ->

  if msg.match[1] in ['maps', 'players']

    return msg.reply(":: #{topToday.call(@, msg.match[1])}")

  return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.mistake'))} i don't keep track of those things...")

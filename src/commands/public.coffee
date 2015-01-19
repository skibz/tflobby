topToday = (entity) ->

  today = @brain.get('tflobby.today') ? { players: {}, maps: {} }

  unless today?
    return 'i haven\'t captured any daily data yet...'

  response = '||'

  unless Object.keys(today[entity]).length
    return "i haven't captured any daily #{entity} data yet..."

  response += " #{entity}: #{times} |" for entity, times of today[entity]
  return "#{response}|"

exports.status = (msg) ->

  lobby = @brain.get('tflobby.lobby')

  unless lobby?
    return msg.reply(":: no pickup to report - create one with !sg or !add")

  players = lobby.names()

  return msg.send(":: #{lobby.server} : #{lobby.map} : #{players.length}/#{lobby.format()} : [ #{players.join(', ')} ] ::")

exports.previous = (msg) ->
  previous = @brain.get('tflobby.previous')

  unless previous?
    return msg.reply(":: no previous match data...")

  return msg.send(":: started by #{previous.principal} : #{previous.server} : #{previous.map} : [ #{lobby.names().join(', ')} ] : #{new Date(previous.createdAt).toString()} ::")

exports.top = (msg) ->

  if msg.match[1] in ['maps', 'players']
    return msg.reply(":: #{topToday.call(@, msg.match[1])}")
  else
    return msg.reply(":: #{msg.random(@brain.get('tflobby.chat.mistake'))} i don't keep track of those things...")

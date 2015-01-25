Rcon = require('../rcon.coffee')

exports.rconSay = (msg) ->
  user = msg.message.user.id
  server = servers[msg.match[3].toLowerCase()]

  if @auth.hasRole(msg.envelope.user, 'rcon')

    if server?.rcon
      return new Rcon(server, (ctx) ->
        return ctx.exec("sm_say #{user}: #{msg.match[2]}", (res) ->
          ctx.close()
          return msg.reply(":: your message was delivered...")
        )
      )

    return msg.reply("the server `#{msg.match[3]}` doesn't exist...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.rconRoster = (msg) ->
  user = msg.message.user.id

  if @auth.hasRole(msg.envelope.user, 'rcon')

    previous = @brain.get('tflobby.previous')
    server = servers[previous.server]

    if previous? and server?.rcon
      return new Rcon(server, (ctx) ->
        return ctx.exec("sm_say [ #tfbot ] #{previous.names().join(', ')}", (res) ->
          ctx.close()
          return msg.reply(":: player roster sent to `#{server.name}`...")
        )
      )

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.affirmative'))} there's no previous game data. creepy...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

exports.rconMap = (msg) ->
  user = msg.message.user.id
  server = servers[msg.match[2].toLowerCase()]
  map = msg.match[3].toLowerCase()

  if @auth.hasRole(msg.envelope.user, 'rcon')

    if server?

      if server.rcon?

        allMaps = @brain.get('tflobby.maps.all')
        filtered = allMaps.filter (map) -> map.indexOf(msg.match[2]) isnt -1

        if filtered.length is 1

          return new Rcon(server, (ctx) ->
            return ctx.exec("changelevel #{filtered[0]}", (res) ->
              ctx.close()
              return msg.reply(":: changing map to `#{filtered[0]}`...")
            )
          )

        return msg.reply(":: which map did you mean? #{filtered.join(', ')}...")

      return msg.reply(":: an rcon password isn't set for that server...")

    return msg.reply(":: the server `#{msg.match[2]}` doesn't exist...")

  return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

Rcon = require('../lib/rcon.coffee')

module.exports =

  rconSay: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'rcon')

      user = msg.message.user.id
      server = @brain.get('tflobby.servers.all')[msg.match[3].toLowerCase()]

      if server?

        if server.rcon?

          return new Rcon server, (err, ctx) ->

            return msg.reply(':: a rcon error ocurred...') if err

            return ctx.exec "sm_say [via IRC] #{user}: #{msg.match[2]}", (res) ->

              ctx.close()
              return msg.reply(":: your message was delivered...")

        return msg.reply(":: an rcon password isn't set for that server...")

      return msg.reply("server `#{msg.match[3]}` doesn't exist...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

  rconRoster: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'rcon')

      lobby = @brain.get('tflobby.previous')

      if lobby?

        if lobby.server.rcon?

          return new Rcon lobby.server, (err, ctx) ->

            return msg.reply(':: a rcon error ocurred...') if err

            return ctx.exec "sm_say [ #tfbot ] #{lobby.players().join(', ')}", (res) ->

              ctx.close()
              return msg.reply(":: player roster sent to `#{server.name}`...")

        return msg.reply(":: an rcon password isn't set for that server...")

      return msg.reply("#{msg.random(@brain.get('tflobby.chat.affirmative'))} there's no game data. creepy...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

  rconMap: (msg) ->

    if @auth.hasRole(msg.envelope.user, 'rcon')

      server = @brain.get('tflobby.servers.all')[msg.match[2].toLowerCase()]

      if server?

        if server.rcon?

          map = msg.match[3].toLowerCase()
          filtered = @brain.get('tflobby.maps.all').filter (map) ->
            map.indexOf(msg.match[2]) isnt -1

          if filtered.length is 1

            return new Rcon server, (err, ctx) ->

              return msg.reply(':: a rcon error ocurred...') if err

              return ctx.exec "changelevel #{filtered[0]}", (res) ->

                ctx.close()
                return msg.reply(":: changing map to `#{filtered[0]}`...")

          return msg.reply(":: which map did you mean? #{filtered.join(', ')}...")

        return msg.reply(":: an rcon password isn't set for that server...")

      return msg.reply(":: the server `#{msg.match[2]}` doesn't exist...")

    return msg.reply("#{msg.random(@brain.get('tflobby.chat.mistake'))} you can't to do that...")

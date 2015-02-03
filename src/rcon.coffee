srcon = require('simple-rcon')

class Rcon

  constructor: (server, fn) ->

    return unless server?

    ctx = new srcon(server.host, server.port, server.rcon)

    ctx
      .on 'error', (err) -> return fn(err, null)
      .on 'authenticated', -> return fn(null, ctx)

module.exports = Rcon

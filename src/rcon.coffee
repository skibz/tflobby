srcon = require('simple-rcon')

class Rcon

  constructor: (server, fn) ->

    return unless server?

    ctx = new srcon(server.host, server.port, server.rcon)

    ctx
      .on 'error', (err) -> console.error('rcon error', err)
      .on 'authenticated', -> return fn(ctx)

module.exports = Rcon

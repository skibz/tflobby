SimpleRcon = require('simple-rcon')

class Rcon

  constructor: (@server, fn) ->

    return unless @server?

    ctx = new SimpleRcon(@server.host, @server.port, @server.rcon)

    return ctx.on 'authenticated', -> return fn(ctx)

module.exports = Rcon

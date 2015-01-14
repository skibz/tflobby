class Rcon

  constructor: (server, fn) ->
    @server = server
    ctx = new (require 'simple-rcon')(@server.host, @server.port, @server.rcon)
    ctx.on('error', ((err) -> console.error('rcon error', err)))
       .on('authenticated', ( -> return fn(ctx)))

module.exports = Rcon

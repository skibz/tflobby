class Lobby

  constructor: (@map, @principal, @server, format) ->
    @playersPerSide = format ? 6
    @createdAt = (new Date()).toJSON()
    @players = {}
    @finalising = false

  format: -> @playersPerSide * 2
  names: -> Object.keys(@players)
  added: -> Object.keys(@players).length
  add: (name) -> @players[name] = name
  rem: (name) -> delete @players[name]
  set: (property, value) ->
    if {}.hasOwnProperty.call(@, property)
      @[property] = value
    return @

module.exports = Lobby

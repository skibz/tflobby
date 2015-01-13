class Lobby

  constructor: (map, principal, server, format) ->
    @map = map
    @principal = principal
    @server = server
    @playersPerSide = format ? 6
    @createdAt = (new Date()).toJSON()
    @participants = {}
    @finalising = false

  format: -> @playersPerSide * 2

  names: -> Object.keys(@participants)

  set: (property, value) -> @[property] = value if {}.hasOwnProperty.call(@, property)

module.exports = Lobby

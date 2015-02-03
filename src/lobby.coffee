class Lobby

  # constructor: (@map, @principal, @server) ->
  constructor: (@map, @principal, @server) ->
    @playersPerSide = 6
    @createdAt = (new Date()).toJSON()
    @participants = {}
    @finalising = false

  ###*
   * return total available slots for the lobby
   * @return {number}
  ###
  slots: ->
    return @playersPerSide * 2

  ###*
   * return an array of participating players
   * @return {array}
  ###
  players: ->
    return Object.keys(@participants)

  ###*
   * return the number of participating players
   * @return {number}
  ###
  totalPlayers: ->
    return Object.keys(@participants).length

  ###*
   * list a given player as participating
   * @param {string} name
   * @return {object}      of type Lobby
  ###
  add: (name) ->
    @participants[name] = name
    return @

  ###*
   * unlist a given player as participating
   * @param  {string} name
   * @return {object}      of type Lobby
  ###
  rem: (name) ->
    delete @participants[name]
    return @

  ###*
   * whether the given player has added to the lobby
   * @param  {string}  player name of player
   * @return {Boolean}        if player has added
  ###
  isAdded: (player) ->
    return player in Object.keys(@participants)

  ###*
   * whether the lobby doesn't have empty slots
   * @return {Boolean}
  ###
  isFull: ->
    return Object.keys(@participants) is @playersPerSide * 2

  ###*
   * change a given property to value
   * @param {string} property name of property
   * @param {mixed}  value    value of property
   * @return {object}         of type Lobby
  ###
  set: (property, value) ->
    if {}.hasOwnProperty.call(@, property)
      @[property] = value
    return @

  ###*
   * return the value of the given property
   * @param  {string} property name of the object property
   * @return {mixed}           the property's value
  ###
  get: (property) ->
    return @[property]

module.exports = Lobby

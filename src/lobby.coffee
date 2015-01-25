class Lobby

  constructor: (@map, @principal, @server, format) ->
    @playersPerSide = format ? 6
    @createdAt = (new Date()).toJSON()
    @players = {}
    @finalising = false

  ###*
   * return total available slots for the lobby
   * @return {number}
  ###
  format: ->
    return @playersPerSide * 2

  ###*
   * return an array of participating players
   * @return {array}
  ###
  names: ->
    return Object.keys(@players)

  ###*
   * return the number of participating players
   * @return {number}
  ###
  added: ->
    return Object.keys(@players).length

  ###*
   * list a given player as participating
   * @param {string} name
   * @return {object}      of type Lobby
  ###
  add: (name) ->
    @players[name] = name
    return @

  ###*
   * unlist a given player as participating
   * @param  {string} name
   * @return {object}      of type Lobby
  ###
  rem: (name) ->
    delete @players[name]
    return @

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

module.exports = Lobby

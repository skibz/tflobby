{expect} = require 'chai'
hubot = require 'actuator'

# todo
# 
# make passes at using hubot.robot 
# to mock state in the application
# for each spec

beforeEach (done) ->
  hubot.initiate(script: '../scripts/tflobby.coffee', done)

afterEach ->
  hubot.terminate()

describe 'hubot help commands', ->

  it 'should have 12 help commands', (done) ->
    expect(hubot.robot.helpCommands()).to.have.length(12)
    done()

  it 'should parse help', (done) ->
    hubot.on('hubot help')
      .spread (response) ->
        expect(response).to.equal """
        hubot rcon say <message> on <server> - sends <message> via rcon to <server>. limited to `rcon` roles.
        hubot rcon list on <server> - sends the player roster from the previous lobby to <server>. limited to `rcon` roles.
        hubot rcon change map on <server> to <mapname> - changes the map on <server> to <mapname>. limited to `rcon` roles.
        hubot sg <mapname> - creates a new lobby with the map set to <mapname>. limited to `officer` roles.
        hubot cg - cancels a running lobby. limited to `officer` roles.
        hubot add <me|user> - adds <user> to the lobby. addition of other users is limited to `officer` roles.
        hubot rem <me|user> - removes <user> from the lobby. removal of other users is limited to `officer` roles.
        hubot map <mapname> - changes the lobby map to <mapname>. limited to `officer` roles.
        hubot server <servername> - changes the lobby server to <servername>. limited to `officer` roles.
        hubot status - reports the lobby status
        hubot previous - reports the previous lobby status
        hubot top <maps|players> - reports the daily counter data accumulated for either maps or players
        hubot shout - reports the current lobby status to the configured steam group via the antino.co.za web service. limited to `officer` roles.
        """
      .done(done.bind(@, null), done)

describe 'hubot rcon', ->

  describe 'say|message|msg', ->
    
    it 'should respond with an error if an invalid server is given', (done) ->
      hubot.on('hubot rcon say hello on notarealserver')
        .spread (response) ->
          expect(response).to.contain 'that\'s not a valid server...'
        .done(done.bind(@, null), done)

    it 'should allow messages to be sent to a server', (done) ->
      hubot.on('hubot rcon say hello on is1')
        .spread (response) ->
          expect(response).to.contain 'your message was delivered...'
        .done(done.bind(@, null), done)

  describe 'list|the list|roster|players', ->

    it 'should respond with an error if there is no previous match data', (done) ->
      hubot.on('hubot rcon list on is1')
        .spread (response) ->
          expect(response).to.contain 'there\'s no previous game data. creepy...'
        .done(done.bind(@, null), done)

  describe 'change map|changelevel|map', ->

    it 'should respond with an error if the given map name is invalid', (done) ->
      hubot.on('hubot rcon map on is1 to fakemapname')
        .spread (response) ->
          expect(response).to.contain 'i\'m not familiar with that map...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the given server is invalid', (done) ->
      hubot.on('hubot rcon map on fakeserver to cp_badlands')
        .spread (response) ->
          expect(response).to.contain 'it seems that server doesn\'t exist...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the rcon password is unknown', (done) ->
      hubot.on('hubot rcon map on mweb5 to cp_badlands')
        .spread (response) ->
          expect(response).to.contain 'i don\'t know the rcon password for that server...'
        .done(done.bind(@, null), done)

describe 'hubot lobby', ->

  describe 'sg|new', ->

    it 'should choose a random map if garbage is given', (done) ->
      hubot.on('hubot sg lasjdflas')
        .spread (response) ->
          expect(response).to.contain '| [  ] ||'
        .done(done.bind(@, null), done)

    it 'should create a new pickup with the given map', (done) ->
      hubot.on('hubot sg cp_badlands')
        .spread (response) ->
          lobby = robot.brain.get('lobby')
          expect(response).to.equal '|| cp_badlands | 0/12 | [  ] ||'
          expect(lobby).to.have.property('map')
          expect(lobby).to.have.property('participants')
          expect(lobby).to.have.property('finalising')
          expect(lobby).to.have.property('principal')
          expect(lobby).to.have.property('server')
        .done(done.bind(@, null), done)

    it 'should filter and select a single map if a partial name is given', (done) ->
      hubot.on('hubot sg badl')
        .spread (response) ->
          expect(response).to.equal '|| cp_badlands | 0/12 | [  ] ||'
        .done(done.bind(@, null), done)

  describe 'cg|kill', ->

    it 'should respond with an error if no pickup is running', (done) ->
      hubot.on('hubot cg')
        .spread (response) ->
          expect(response).to.contain 'there\'s no pickup filling...'
        .done(done.bind(@, null), done)

  describe 'add me|username', ->

    it 'should add a nickname to a lobby', (done) ->
      hubot.on('hubot cg')
      hubot.on('hubot add abcd')
        .spread (response) ->
          expect(response).to.contain '| 1/12 | [ abcd ] ||'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the given nickname is already added', (done) ->
      hubot.on('hubot cg')
      hubot.on('hubot add abcd')
      hubot.on('hubot add abcd')
        .spread (response) ->
          expect(response).to.contain 'already added...'
        .done(done.bind(@, null), done)

    it 'should responsd with an error if the lobby is full', (done) ->

      lobby =
        participants:
          1: 0
          2: 0
          3: 0
          4: 0
          5: 0
          6: 0
          7: 0
          8: 0
          9: 0
          10: 0
          11: 0
          12: 0

      hubot.robot.set 'lobby', lobby

      hubot.on('hubot add 13')
        .spread (response) ->
          expect(response).to.contain 'the pickup is already full...'
        .done(done.bind(@, null), done)

  describe 'rem me|username', ->

    it 'should respond with an error if no lobby is filling', (done) ->

      hubot.robot.lobby.set 'lobby', null

      hubot.on('hubot rem me')
        .spread (response) ->
          expect(response).to.contain 'no pickup filling...'
        .done(done.bind(@, null), done)

    it 'should remove a given user from a lobby', (done) ->
      lobby =
        participants:
          asdf: 'asdf'
      
      hubot.robot.set 'lobby', lobby

      hubot.on('hubot rem asdf')
        .spread (response) ->
          expect(response).to.contain '| 0/12 | [  ] ||'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the given user is not listed in the lobby', (done) ->
      lobby =
        participants:
          lkajsdf: 'lkajsdf'

      hubot.robot.set 'lobby', lobby

      hubot.on('hubot rem lkjasdf')
        .spread (response) ->
          expect(response).to.contain 'added to the pickup...'
        .done(done.bind(@, null), done)

  describe 'map mapname', ->

    it 'should respond with an error if no lobby is filling', (done) ->
      
      lobby =
        map: ''

      hubot.robot.set 'lobby', lobby
      
      hubot.on('hubot map lkjasfd')
        .spread (response) ->
          expect(response).to.contain 'no pickup filling...'
        .done(done.bind(@, null), done)

    it 'should change the map to the given mapname', (done) ->
      lobby =
        map: 'cp_snakewater_final1'

      hubot.robot.set 'lobby', lobby

      hubot.on('hubot map badl')
        .spread (response) ->
          expect(response).to.contain 'changing map to cp_badlands...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the map doesn\'t exist', (done) ->
      hubot.on('hubot add lkjasdf')
      hubot.on('hubot map kasldfjladf')
        .spread (response) ->
          expect(response).to.contain 'i don\'t know that map...'
        .done(done.bind(@, null), done)

  describe 'server servername', ->

    it 'should respond with an error if no pickup is filling', (done) ->
      hubot.on('hubot server asdlfkja')
        .spread (response) ->
          expect(response).to.contain 'no pickup filling...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if an invalid server name is given', (done) ->
      hubot.on('hubot add me')
      hubot.on('hubot server lkajsdf')
        .spread (response) ->
          expect(response).to.contain 'isn\'t a valid server...'
        .done(done.bind(@, null), done)

    it 'should change the server to the given server name', (done) ->
      hubot.on('hubot add me')
      hubot.on('hubot server is1')
        .spread (response) ->
          expect(response).to.contain 'changing the server to is1...'
        .done(done.bind(@, null), done)

  describe 'status', ->

    it 'should respond with an error if no pickup is filling', (done) ->
      hubot.on('hubot status')
        .spread (response) ->
          expect(response).to.contain 'no pickup filling...'
        .done(done.bind(@, null), done)

    it 'should respond with the pickup status if there\'s a pickup filling', (done) ->
      hubot.on('hubot add 123')
      hubot.on('hubot status')
        .spread (response) ->
          expect(response).to.contain '| 1/12 | [ 123 ] ||'
        .done(done.bind(@, null), done)

  describe 'previous', ->

    it 'should respond with an error if there is no previous match data', (done) ->
      hubot.on('hubot previous')
        .spread (response) ->
          expect(response).to.contain 'no previous match data...'
        .done(done.bind(@, null), done)

    it 'should respond with previous match data if any exists', (done) ->
      date = new Date()
      previous =
        principal: 'somebody'
        server: 'mweb1'
        map: 'cp_badlands'
        participants:
          somebody: 'somebody'
        createdAt: date.toString()

      hubot.robot.brain.set 'previous', previous
      hubot.on('hubot previous')
        .spread (response) ->
          expect(response).to.contain "|| somebody | mweb1 | cp_badlands | [ somebody ] | #{date.toString()} ||"
        .done(done.bind(@, null), done)

  describe 'top maps|players', ->

    it 'should respond with an error if no data has been collected', (done) ->
      hubot.on('hubot top players')
        .spread (response) ->
          expect(response).to.contain 'i haven\'t captured any daily data yet...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if no map data has been collected', (done) ->
      hubot.on('hubot top maps')
        .spread (response) ->
          expect(response).to.contain 'i haven\'t captured any daily map data yet...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if no player data has been collected', (done) ->
      hubot.on('hubot top players')
        .spread (response) ->
          expect(response).to.contain 'i haven\'t captured any daily player data yet...'
        .done(done.bind(@, null), done)

    it 'should respond with daily map data if any exists', (done) ->
      today =
        maps:
          cp_badlands: 1
      hubot.robot.brain.set 'today', today
      hubot.on('hubot top maps')
        .spread (response) ->
          expect(response).to.equal '|| cp_badlands: 1 ||'
        .done(done.bind(@, null), done)

    it 'should respond with daily player data if any exists', (done) ->
      today =
        players:
          somebody: 1
      hubot.robot.brain.set 'today', today
      hubot.on('hubot top players')
        .spread (response) ->
          expect(response).to.equal '|| somebody: 1 ||'
        .done(done.bind(@, null), done)

  describe 'shout', ->

    it 'should respond with an error if no lobby is filling', (done) ->
      hubot.on('hubot shout')
        .spread (response) ->
          expect(response).to.contain 'there\'s no pickup filling...'
        .done(done.bind(@, null), done)

    it 'should respond with an error if the lobby\'s shout has already been used', (done) ->
      lobby =
        shouted: true
      hubot.robot.brain.set 'lobby', lobby
      hubot.on('hubot shout')
        .spread (response) ->
          expect(response).to.contain 'you\'ve expended your shout, ouch...'
        .done(done.bind(@, null), done)

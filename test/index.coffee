chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
chai.use require 'sinon-chai'

describe 'tfbot', ->

  beforeEach ->

    @robot =
      enter   : sinon.spy()
      leave   : sinon.spy()
      respond : sinon.spy()

    require('../src/index.coffee')(@robot)

  describe 'lifecycle module', ->

    describe 'listeners', ->

      it 'should register enter/leave listeners', ->

        expect(@robot.enter).to.have.been.called
        expect(@robot.leave).to.have.been.called

      it 'should register respond listeners', ->

        expect(@robot.respond).to.have.been.calledWith(/add (.*)|add/i)
        expect(@robot.respond).to.have.been.calledWith(/rem (.*)|rem/i)

    describe 'commands', ->

      describe '!add', ->

        it 'should match with input strings', ->

          expect('add').to.match(/add (.*)|add/i)
          expect('add me').to.match(/add (.*)|add/i)
          expect('add abc').to.match(/add (.*)|add/i)

      describe '!rem', ->

        it 'should match with input strings', ->

          expect('rem').to.match(/rem (.*)|rem/i)
          expect('rem me').to.match(/rem (.*)|rem/i)
          expect('rem abc').to.match(/rem (.*)|rem/i)

  describe 'community module', ->

    describe 'listeners', ->

      it 'should register respond listeners', ->

        expect(@robot.respond).to.have.been.calledWith(/status|games/i)
        expect(@robot.respond).to.have.been.calledWith(/previous|lastgame/i)
        expect(@robot.respond).to.have.been.calledWith(/(top|today) (maps|players)/i)

    describe 'commands', ->

      describe '!status', ->

        it 'should match with input strings', ->

          expect('status').to.match(/status|games/i)
          expect('games').to.match(/status|games/i)

      describe '!previous', ->

        it 'should match with input strings', ->

          expect('previous').to.match(/previous|lastgame/i)
          expect('lastgame').to.match(/previous|lastgame/i)

      describe '!top', ->

        it 'should match with input strings', ->

          expect('top maps').to.match(/(top|today) (maps|players)/i)
          expect('top players').to.match(/(top|today) (maps|players)/i)
          expect('today maps').to.match(/(top|today) (maps|players)/i)
          expect('today players').to.match(/(top|today) (maps|players)/i)

  describe 'rcon module', ->

    describe 'listeners', ->

      it 'should register respond listeners', ->

        expect(@robot.respond).to.have.been.calledWith(/rcon (say|message|msg) (.*) to (.*)/i)
        expect(@robot.respond).to.have.been.calledWith(/rcon send (list|the list|roster|players) to (.*)/i)
        expect(@robot.respond).to.have.been.calledWith(/rcon (change map|changelevel|map) on (.*) to (.*)/i)

    describe 'commands', ->

      describe '!rcon say', ->

        it 'should match with input strings', ->

          expect('rcon say abc to abc').to.match(/rcon (say|message|msg) (.*) to (.*)/i)
          expect('rcon message abc to abc').to.match(/rcon (say|message|msg) (.*) to (.*)/i)
          expect('rcon msg abc to abc').to.match(/rcon (say|message|msg) (.*) to (.*)/i)

      describe '!rcon send', ->

        it 'should match with input strings', ->

          expect('rcon send list to abc').to.match(/rcon send (list|the list|roster|players) to (.*)/i)
          expect('rcon send the list to abc').to.match(/rcon send (list|the list|roster|players) to (.*)/i)
          expect('rcon send roster to abc').to.match(/rcon send (list|the list|roster|players) to (.*)/i)
          expect('rcon send players to abc').to.match(/rcon send (list|the list|roster|players) to (.*)/i)

      describe '!rcon map', ->

        it 'should match with input strings', ->

          expect('rcon change map on abc to abc').to.match(/rcon (change map|changelevel|map) on (.*) to (.*)/i)
          expect('rcon changelevel on abc to abc').to.match(/rcon (change map|changelevel|map) on (.*) to (.*)/i)
          expect('rcon map on abc to abc').to.match(/rcon (change map|changelevel|map) on (.*) to (.*)/i)

  describe 'admin module', ->

    describe 'listeners', ->

      it 'should register respond listeners', ->

        expect(@robot.respond).to.have.been.calledWith(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
        expect(@robot.respond).to.have.been.calledWith(/cg|kill/i)
        expect(@robot.respond).to.have.been.calledWith(/format (.*)/i)
        expect(@robot.respond).to.have.been.calledWith(/(random (.*) map)|(map (.*))/i)
        expect(@robot.respond).to.have.been.calledWith(/server (.*)/i)
        expect(@robot.respond).to.have.been.calledWith(/change (.*) to (.*)/i)

    describe 'commands', ->

      describe '!sg', ->

        it 'should match with input strings', ->

          expect('sg').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
          expect('new').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
          expect('sg abc').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
          expect('new abc').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
          expect('sg random abc map').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)
          expect('new random abc map').to.match(/((sg|new))|((sg|new) (.*))|((sg|new) random (.*) map)/i)

      describe '!cg', ->

        it 'should match with input strings', ->

          expect('cg').to.match(/cg|kill/i)
          expect('kill').to.match(/cg|kill/i)

      describe '!format', ->

        it 'should match with input strings', ->

          expect('format 5').to.match(/format (.*)/i)

      describe '!map', ->

        it 'should match with input strings', ->

          expect('random abc map').to.match(/(random (.*) map)|(map (.*))/i)
          expect('map abc').to.match(/(random (.*) map)|(map (.*))/i)

      describe '!server', ->

        it 'should match with input strings', ->

          expect('server abc').to.match(/server (.*)/i)

      describe '!change', ->

        it 'should match with input strings', ->

          expect('change abc to abc').to.match(/change (.*) to (.*)/i)

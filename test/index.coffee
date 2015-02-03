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

    require('../src')(@robot)

  describe 'lifecycle commands', ->

    it 'registers enter/leave listeners', ->

      expect(@robot.enter).to.have.been.called
      expect(@robot.leave).to.have.been.called

    it 'registers respond listeners', ->

      expect(@robot.respond).to.have.been.calledWith(/(add|add (me|.*))/i)
      expect(@robot.respond).to.have.been.calledWith(/(rem|rem (me|.*))/i)

  describe 'community commands', ->

    it 'registers respond listeners', ->

      expect(@robot.respond).to.have.been.calledWith(/(status|games)/i)
      expect(@robot.respond).to.have.been.calledWith(/(previous|lastgame)/i)
      expect(@robot.respond).to.have.been.calledWith(/(top|today) (maps|players)/i)

  describe 'rcon commands', ->

    it 'registers respond listeners', ->

      expect(@robot.respond).to.have.been.calledWith(/rcon (say|message|msg) (.*) on (.*)/i)
      expect(@robot.respond).to.have.been.calledWith(/rcon send (list|the list|roster|players) on (.*)/i)
      expect(@robot.respond).to.have.been.calledWith(/rcon (change map|changelevel|map) on (.*) to (.*)/i)

  describe 'admin commands', ->

    it 'registers respond listeners', ->

      expect(@robot.respond).to.have.been.calledWith(/((sg|new)|(sg|new) (.*)|(sg|new) random (.*) map)/i)
      expect(@robot.respond).to.have.been.calledWith(/(cg|kill)/i)
      expect(@robot.respond).to.have.been.calledWith(/format (.*)/i)
      expect(@robot.respond).to.have.been.calledWith(/(random (.*) map|map (.*))/i)
      expect(@robot.respond).to.have.been.calledWith(/server (.*)/i)
      expect(@robot.respond).to.have.been.calledWith(/change (.*) to (.*)/i)

noflo = require 'noflo'

if noflo.isBrowser()
  ObjectStore = require 'noflo-thegrid/components/ObjectStore.js'
else
  chai = require 'chai' unless chai
  sinon = require 'sinon'
  ObjectStore = require '../components/ObjectStore.coffee'

expect = chai.expect unless expect


describe 'ObjectStore', ->

  c = null
  inIn = null
  updateIn = null
  outOut = null
  callback = null

  beforeEach ->
    c = ObjectStore.getComponent()
    callback = sinon.spy()

    inIn = noflo.internalSocket.createSocket()
    updateIn = noflo.internalSocket.createSocket()
    outOut = noflo.internalSocket.createSocket()

    c.inPorts.in.attach inIn
    c.inPorts.update.attach updateIn
    c.outPorts.out.attach outOut

  describe 'inPorts', ->

    it 'should include "in"', ->
      expect(c.inPorts.in).to.be.an 'object'

    it 'should include "update"', ->
      expect(c.inPorts.update).to.be.an 'object'

  describe 'outPorts', ->

    it 'should include "out"', ->
      expect(c.outPorts.out).to.be.an 'object'

  describe 'data flow', ->

    describe 'with data on the "in" port only', ->

      it 'should not send the object to the "out" port', ->
        outOut.on 'data', callback

        inIn.send {test: true}

        expect(callback.called).to.be.false

    describe 'with data on "update" and "in" port', ->

      it 'should send the updated object to the outport', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
            another: 'test'
          done()

        updateIn.send another: 'test'
        inIn.send test: true

      it 'should consume the "update" port with data on "in"', ->
        updateIn.send another: 'test'
        inIn.send test: true

        outOut.on 'data', callback

        inIn.send unrelated: 'data'

        expect(callback.called).to.be.false

    describe 'with data on first "in" and later "update" port', ->

      it 'should send the updated object to the outport', (done) ->
        inIn.send test: true

        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
            another: 'test'
          done()

        updateIn.send another: 'test'

      it 'should consume the "update" port with data on "in"', ->
        inIn.send test: true
        updateIn.send another: 'test'

        outOut.on 'data', callback

        inIn.send unrelated: 'data'

        expect(callback.called).to.be.false

      it 'should disconnect the "out" port', (done) ->
        inIn.send {test: true}

        outOut.on 'disconnect', ->
          done()

        updateIn.send another: 'test'

    describe 'with multiple "in" signals', ->

      it 'should only send once', ->
        outOut.on 'data', callback

        updateIn.send another: 'test'
        inIn.send {test: 1}
        inIn.send {test: 2}
        inIn.send {test: 3}
        inIn.send {test: 4}

        expect(callback.callCount).to.equal 1

    describe 'with multiple "update" signals', ->

      it 'should send each one', ->
        outOut.on 'data', callback

        inIn.send {test: true}
        updateIn.send another: 'test1'
        updateIn.send another: 'test2'
        updateIn.send another: 'test3'
        updateIn.send another: 'test4'

        expect(callback.callCount).to.equal 4

  describe 'error handling', ->

    describe 'with invalid data on the "in" port', ->

      it 'should throw an error', ->
        expect(-> inIn.send 'wtf').to.throw TypeError

    describe 'with invalid data on the "update" port', ->

      it 'should throw an error', ->
        expect(-> updateIn.send 'wtf').to.throw TypeError

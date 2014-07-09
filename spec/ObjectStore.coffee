noflo = require 'noflo'
if noflo.isBrowser()
  ObjectStore = require 'noflo-thegrid/components/ObjectStore.js'
else
  chai = require 'chai' unless chai
  ObjectStore = require '../components/ObjectStore.coffee'

expect = chai.expect unless expect


describe 'ObjectStore', ->

  c = null
  inIn = null
  updateIn = null
  outOut = null

  beforeEach ->
    c = ObjectStore.getComponent()

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

    describe 'with data on the "in" port', ->

      it 'should send the object to the "out" port', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
          done()

        inIn.send {test: true}

    describe 'with data on first "update" and later "in" port', ->

      it 'should send the updated object to the outport', (done) ->
        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
            another: 'test'
          done()

        updateIn.send another: 'test'
        inIn.send test: true

      it 'should consume the "update" port with data on "in"', (done) ->
        updateIn.send another: 'test'
        inIn.send test: true

        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            unrelated: 'data'
          done()

        inIn.send unrelated: 'data'

    describe 'with data on first "in" and later "update" port', ->

      it 'should send the updated object to the outport', (done) ->
        inIn.send test: true

        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            test: true
            another: 'test'
          done()

        updateIn.send another: 'test'

      it 'should consume the "update" port with data on "in"', (done) ->
        inIn.send test: true
        updateIn.send another: 'test'

        outOut.on 'data', (data) ->
          expect(data).to.deep.equal
            unrelated: 'data'
          done()

        inIn.send unrelated: 'data'

  describe 'error handling', ->

    describe 'with invalid data on the "in" port', ->

      it 'should throw an error', ->
        expect(-> inIn.send 'wtf').to.throw TypeError

    describe 'with invalid data on the "update" port', ->

      it 'should throw an error', ->
        expect(-> updateIn.send 'wtf').to.throw TypeError

noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  CreatePost = require '../components/CreatePost.coffee'
else
  CreatePost = require 'noflo-thegrid/components/CreatePost.js'

describe 'CreatePost component', ->
  c = null
  ins = null
  token = null
  out = null
  beforeEach ->
    c = CreatePost.getComponent()
    ins = noflo.internalSocket.createSocket()
    token = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.item.attach ins
    c.inPorts.token.attach token
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an item port', ->
      chai.expect(c.inPorts.item).to.be.an 'object'
    it 'should have an token port', ->
      chai.expect(c.inPorts.token).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have an error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

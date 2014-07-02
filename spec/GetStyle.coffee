noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetStyle = require '../components/GetStyle.coffee'
else
  GetStyle = require 'noflo-thegrid/components/GetStyle.js'

describe 'GetStyle component', ->
  c = null
  theme = null
  layout = null
  ordered = null
  token = null
  out = null
  beforeEach ->
    c = GetStyle.getComponent()
    theme = noflo.internalSocket.createSocket()
    layout = noflo.internalSocket.createSocket()
    ordered = noflo.internalSocket.createSocket()
    token = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.theme.attach theme
    c.inPorts.layout.attach layout
    c.inPorts.ordered.attach ordered
    c.inPorts.token.attach token
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have a theme port', ->
      chai.expect(c.inPorts.theme).to.be.an 'object'
    it 'should have a layout port', ->
      chai.expect(c.inPorts.layout).to.be.an 'object'
    it 'should have an ordered port', ->
      chai.expect(c.inPorts.ordered).to.be.an 'object'
    it 'should have an token port', ->
      chai.expect(c.inPorts.token).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have an error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

noflo = require 'noflo'
if noflo.isBrowser()
  PostServerData = require 'noflo-thegrid/components/PostServerData.js'
else
  chai = require 'chai' unless chai
  PostServerData = require '../components/PostServerData.coffee'

expect = chai.expect unless expect


describe 'PostServerData', ->

  c = null

  beforeEach ->
    c = PostServerData.getComponent()

  describe 'in-ports', ->

    it 'should contain a "endpoint" port', ->
      expect(c.inPorts.endpoint).to.be.an 'object'

    it 'should contain a "data" port', ->
      expect(c.inPorts.data).to.be.an 'object'

    it 'should contain a "token" port', ->
      expect(c.inPorts.token).to.be.an 'object'

  describe 'out-ports', ->

    it 'should contain a "data" port', ->
      expect(c.outPorts.data).to.be.an 'object'

    it 'should contain a "error" port', ->
      expect(c.outPorts.error).to.be.an 'object'

    it 'should contain a "status" port', ->
      expect(c.outPorts.status).to.be.an 'object'

if noflo.isBrowser()

  describe 'PostServerData http calls', ->

    xhr = null
    requests = null
    c = null
    endpointIn = null
    dataIn = null
    tokenIn = null
    dataOut = null
    errorOut = null
    statusOut = null

    beforeEach ->
      requests = []
      xhr = sinon.useFakeXMLHttpRequest()
      xhr.onCreate = (xreq) ->
        requests.push xreq

      c = PostServerData.getComponent()
      endpointIn = noflo.internalSocket.createSocket()
      dataIn = noflo.internalSocket.createSocket()
      tokenIn = noflo.internalSocket.createSocket()
      dataOut = noflo.internalSocket.createSocket()
      errorOut = noflo.internalSocket.createSocket()
      statusOut = noflo.internalSocket.createSocket()

      c.inPorts.endpoint.attach endpointIn
      c.inPorts.token.attach tokenIn
      c.inPorts.data.attach dataIn
      c.outPorts.data.attach dataOut
      c.outPorts.error.attach errorOut
      c.outPorts.status.attach statusOut

      tokenIn.send 'token'
      dataIn.send testData: 'stuff'
      endpointIn.send 'http://test.com/api'

    it 'should send request to the server', ->
      expect(requests).to.have.length 1

    it 'should send the request to the proper endpoint', ->
      request = requests.pop()

      expect(request.url).to.equal 'http://test.com/api'

    it 'should use the token to authenticate', ->
      request = requests.pop()

      expect(request.requestHeaders['Authorization']).to.equal 'Bearer token'

    it 'should set the correct "Accept" header', ->
      request = requests.pop()

      expect(request.requestHeaders['Accept']).to.equal 'application/json'

    it 'should use http POST to request data', ->
      request = requests.pop()

      expect(request.method).to.equal 'POST'

    it 'should send the serialized data', ->
      request = requests.pop()

      expect(request.requestBody).to.equal JSON.stringify testData: 'stuff'

    describe 'with a successful response', ->

      responseData = null

      beforeEach ->
        responseData = "[{\"name\": \"filter_1\"}]"

      it 'should parse the response as json', (done) ->
        dataOut.on 'data', (data) ->
          expect(data).to.deep.equal JSON.parse responseData
          done()

        request = requests.pop()
        request.respond 200, 'Content-Type': 'application/json', responseData

      it 'should send the correct status to the out port', (done) ->
        statusOut.on 'data', (data) ->
          expect(data).to.equal 200
          done()

        request = requests.pop()
        request.respond 200, 'Content-Type': 'application/json', responseData

    describe 'with an unsuccessful response', ->

      responseData = null

      beforeEach ->
        responseData = "{\"error\": \"Authentication Failed!\"}"

      it 'should send an error', (done) ->
        errorOut.on 'data', (data) ->
          expect(data).to.deep.equal JSON.parse responseData
          done()

        request = requests.pop()
        request.respond 401, 'Content-Type': 'application/json', responseData

      it 'should send the correct status to the out port', (done) ->
        statusOut.on 'data', (data) ->
          expect(data).to.equal 401
          done()

        request = requests.pop()
        request.respond 401, 'Content-Type': 'application/json', responseData

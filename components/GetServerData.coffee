noflo = require 'noflo'
superagent = require 'superagent'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Uses http GET to retrieve JSON data from an API endpoint.'
  c.endpointGroups = []

  # Defining in-ports.
  c.inPorts.add 'endpoint',
    datatype: 'string'
    description: 'Name of the theme being used.'
  c.inPorts.add 'token',
    datatype: 'string'
    description: 'API token used for authentication.'
    required: true

  # Defining out-ports.
  c.outPorts.add 'data',
    datatype: 'object'
    description: 'The data retrieved from the API endpoint.'
  c.outPorts.add 'status',
    datatype: 'int'
    description: 'The http status code of the response.'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'endpoint'
    params: ['token']
    out: ['data', 'status']
    forwardGroups: true
    async: true
  , (url, groups, outPorts, callback) ->
    superagent.get url
    .set('Authorization', "Bearer #{c.params.token}")
    .set('Accept', 'application/json')
    .end (err, res) ->
      return callback err if err

      outPorts['status'].send res.status
      return callback res.body if res.status >= 400

      outPorts['data'].send res.body
      callback()

  return c

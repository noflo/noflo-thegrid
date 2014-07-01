noflo = require 'noflo'
superagent = require 'superagent'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Create a new TheGrid post'
  c.inPorts.add 'item',
    datatype: 'object'
    description: 'Content item to create'
  c.inPorts.add 'token',
    datatype: 'string'
    description: 'TheGrid API token'
    required: yes
  c.outPorts.add 'out',
    datatype: 'string'

  noflo.helpers.WirePattern c,
    in: 'item'
    params: ['token']
    out: 'out'
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    superagent.post 'https://api.thegrid.io/item'
    .send(data)
    .set('Authorization', "Bearer #{c.params.token}")
    .set('Accept', 'application/json')
    .end (err, res) ->
      return callback err if err
      out.send res.header.location.replace '/item/', ''
      do callback

  c

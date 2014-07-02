noflo = require 'noflo'
superagent = require 'superagent'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Load TheGrid style data'
  c.inPorts.add 'theme',
    datatype: 'string'
    description: 'Theme name'
  c.inPorts.add 'layout',
    datatype: 'string'
    description: 'Layout filter name'
  c.inPorts.add 'ordered',
    datatype: 'boolean'
    description: 'Ordered or unordered style from the filter'
  c.inPorts.add 'token',
    datatype: 'string'
    description: 'TheGrid API token'
    required: yes
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: ['theme', 'layout', 'ordered']
    params: ['token']
    out: 'out'
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    type = if data.ordered then 'article' else 'feed'
    superagent.get "https://api.thegrid.io/item/#{data.theme}/#{data.layout}/#{type}"
    .set('Authorization', "Bearer #{c.params.token}")
    .set('Accept', 'application/json')
    .end (err, res) ->
      return callback err if err
      try
        out.send JSON.parse res.text
      catch e
        return callback e
      do callback

  c

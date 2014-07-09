noflo = require 'noflo'
_ = require 'underscore'


exports.getComponent = ->
  object = null
  updates = {}

  updateAndSend = (data=object) ->
    object = _.extend data, updates
    updates = {}

    c.outPorts.out.send object

  c = new noflo.Component
  c.description = "Stores an object an incrementally updates it with the object
    send to the 'updates' port."

  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to be stored.'

  c.inPorts.add 'update',
    datatype: 'object'
    description: 'Object to merge into stored one.'

  c.outPorts.add 'out',
    datatype: 'object'
    description: 'Updated object.'

  c.inPorts.in.on 'data', (data) ->
    unless data instanceof Object
      throw new TypeError '"in" only accepts objects.'

    updateAndSend data

  c.inPorts.update.on 'data', (data) ->
    unless data instanceof Object
      throw new TypeError '"in" only accepts objects.'

    updates = data

    updateAndSend() if object

  return c

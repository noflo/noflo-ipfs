noflo = require 'noflo'
ipfs = require 'ipfs-api'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'List hashes in IPFS permanent storage'
  c.icon = 'file-text-o'
  c.inPorts.add 'in',
    datatype: 'bang'
  c.inPorts.add 'host',
    datatype: 'string'
    default: '/ip4/127.0.0.1/tcp/5001'
  c.outPorts.add 'hashes',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'hashes'
    params: ['host']
    async: true
    forwardGroups: true
  , (data, groups, out, callback) ->
    api = ipfs c.params?.host
    api.pin.list (err, res) ->
      return callback err if err
      unless res?.Keys
        return callback new Error "No results for IPFS pin list"

      out.send Object.keys res.Keys
      do callback

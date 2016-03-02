noflo = require 'noflo'
ipfs = require 'ipfs-api'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Pin an IPFS hash for permanent storage'
  c.icon = 'file-text-o'
  c.inPorts.add 'hash',
    datatype: 'string'
  c.inPorts.add 'host',
    datatype: 'string'
    default: '/ip4/127.0.0.1/tcp/5001'
  c.outPorts.add 'hash',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'hash'
    out: 'hash'
    params: ['host']
    async: true
    forwardGroups: true
  , (hash, groups, out, callback) ->
    api = ipfs c.params?.host
    api.pin.add hash, (err, res) ->
      return callback err if err
      unless res?.Pinned?.length
        return callback new Error "No results for IPFS pin add"
      out.send res.Pinned[0]
      do callback


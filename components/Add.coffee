noflo = require 'noflo'
ipfs = require 'ipfs-api'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Write contents into IPFS'
  c.icon = 'file-text-o'
  c.inPorts.add 'in',
    datatype: 'string'
  c.inPorts.add 'host',
    datatype: 'string'
    default: '/ip4/127.0.0.1/tcp/5001'
  c.outPorts.add 'hash',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'hash'
    params: ['host']
    async: true
    forwardGroups: true
  , (data, groups, out, callback) ->
    api = ipfs c.params?.host

    if typeof data is 'string'
      data = new Buffer data

    api.add data, (err, res) ->
      return callback err if err
      unless res?.length
        return callback new Error "No results for IPFS add"

      out.send res[0].Hash
      do callback

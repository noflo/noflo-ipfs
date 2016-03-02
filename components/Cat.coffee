noflo = require 'noflo'
ipfs = require 'ipfs-api'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Read contents for an IPFS hash'
  c.icon = 'file-text-o'
  c.inPorts.add 'hash',
    datatype: 'string'
  c.inPorts.add 'host',
    datatype: 'string'
    default: '/ip4/127.0.0.1/tcp/5001'
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'hash'
    out: 'out'
    params: ['host']
    async: true
    forwardGroups: true
  , (hash, groups, out, callback) ->
    api = ipfs c.params?.host
    api.cat hash, (err, res) ->
      return callback err if err
      unless res
        return callback new Error "No results for #{hash}"

      if res.readable
        result = ''
        res.on 'data', (chunk) ->
          result += chunk
        res.on 'end', ->
          out.send result
          do callback
        return

      out.send res
      do callback

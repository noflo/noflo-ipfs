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
    control: true
  c.outPorts.add 'hash',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'host', 'hash'
    [host, data] = input.get 'host', 'hash'
    return unless data.type is 'data'

    api = ipfs host.data
    api.pin.add data.data, (err, res) ->
      return output.sendDone err if err
      unless res?.Pinned?.length
        return output.sendDone new Error "No results for IPFS pin add"
      output.sendDone
        hash: res.Pinned[0]

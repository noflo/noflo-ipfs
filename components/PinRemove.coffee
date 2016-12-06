noflo = require 'noflo'
ipfs = require 'ipfs-api'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Remove an IPFS hash from permanent storage'
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
    api.pin.rm data.data, (err, res) ->
      return output.sendDone err if err
      output.sendDone
        hash: data.data

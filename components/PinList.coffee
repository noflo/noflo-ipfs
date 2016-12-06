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
    control: true
  c.outPorts.add 'hashes',
    datatype: 'array'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'host', 'in'
    [host, data] = input.get 'host', 'in'
    return unless data.type is 'data'

    api = ipfs host.data
    api.pin.ls (err, res) ->
      return output.sendDone err if err
      unless Object.keys(res).length
        return output.sendDone new Error "No results for IPFS pin list"

      output.sendDone
        hashes: Object.keys res

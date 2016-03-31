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
    control: true
  c.outPorts.add 'hash',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'host', 'in'
    [host, data] = input.getData 'host', 'in'
    api = ipfs host

    if typeof data is 'string'
      data = new Buffer data

    api.add data, (err, res) ->
      return output.sendDone err if err
      unless res?.length
        return output.sendDone new Error "No results for IPFS add"
      output.sendDone
        hash: res[0].hash

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
    control: true
  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'host', 'hash'
    [host, data] = input.get 'host', 'hash'
    return unless data.type is 'data'

    api = ipfs host.data
    api.cat data.data, (err, res) ->
      return output.sendDone err if err
      unless res
        return output.sendDone new Error "No results for #{data.data}"

      if res.readable
        result = ''
        res.on 'data', (chunk) ->
          result += chunk
        res.on 'end', ->
          output.sendDone
            out: result
        return

      output.sendDone
        out: res

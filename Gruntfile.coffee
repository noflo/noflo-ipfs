ipfsd = require 'ipfsd-ctl'
ipfs = require 'ipfs-api'

module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffeescript/register'

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'test', ['coffeelint', 'startIPFS', 'mochaTest', 'stopIPFS']
  @registerTask 'default', ['test']

  daemons = []
  grunt = @
  # IPFS daemon control
  @registerTask 'startIPFS', ->
    done = @async()
    ipfsd.create({
      port: 5002
    }).spawn (err, node) ->
      if err
        grunt.log.error err
        return done false
      grunt.log.writeln "IPFS at #{node.apiAddr} started"
      daemons.push node
      api = ipfs node.apiAddr
      # Add the fixtures
      api.add new Buffer("Hello, World!\n"), (err, hash) ->
        if err
          grunt.log.error err
          return done false
        done()

  @registerTask 'stopIPFS', ->
    done = @async()
    unless daemons.length
      return done()

    stop = ->
      return done() if daemons.length < 1
      d = daemons.shift()
      returned = false
      d.stop (err) ->
        return if returned
        returned = true
        if err
          grunt.log.error err
          return done false
        grunt.log.writeln "IPFS at #{d.apiAddr} stopped"
        do stop

    do stop

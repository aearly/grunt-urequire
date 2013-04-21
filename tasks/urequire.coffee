# Supporting uRequire ver >=0.3.0
"use strict"

urequire = require 'urequire'

module.exports = (grunt) ->

  _ = grunt.util._

  grunt.registerMultiTask "urequire", "Convert javascript modules using uRequire", ->

    ### DEPRECATED OLD FORMAT CONFIG ###
    # detect old format's 'options':
    if (@target is 'options') and (_.any grunt.config.get("urequire"), (val, key)->
      key in urequire.Build.templates)

      grunt.log.writeln """
        You are using a *deprecated* grunt-urequire format in your gruntfile.
        Should still work, but you should change it to uRequire/grunt-urequire
        version v0.3 and above.

        Ignoring bogus 'options' task.
      """
    else
      # detect old format & transform it to the new
      if @target in urequire.Build.templates and grunt.config.get("urequire.options")
        @data = _.clone @data, true
        _.extend @data, grunt.config.get("urequire.options")
        @data.template = @target
        grunt.log.writeln """
          You are using a *deprecated* grunt-urequire format in your gruntfile.
          Should still work, but you should change it to uRequire/grunt-urequire
          version v0.3 and above.

          Transformed @data is:
          #{JSON.stringify @data, null, ' '}
        """

      ### The 'real' grunt-urequire task ###
      done = @async()
      @data.done = (doneVal)->
        grunt.log.ok 'grunt-urequire task is done()' if doneVal is true
        done doneVal
        #@todo:1,5 add 'done' to uRequireCOnfig - store it from @data{} first,
        #call it before this done()

      bb = new urequire.BundleBuilder @data, # grunt's config
        grunt.config.get("urequire._defaults"), # grunt's _defaults config
        bundle: bundleName:@target # just add @target as bundleName if missing

      bb.buildBundle()


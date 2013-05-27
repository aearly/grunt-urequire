# Supporting uRequire ver 0.3.0beta1 / 0.3.0beta2
"use strict"

_fs = require 'fs'
urequire = require 'urequire'

module.exports = (grunt) ->

  _ = grunt.util._

  grunt.registerMultiTask "urequire", "Convert javascript modules using uRequire", ->

    ### DEPRECATED OLD FORMAT CONFIG ###
    # detect old format's 'options':
    if (@target is 'options') and (_.any grunt.config.get("urequire"), (val, key)-> key in urequire.Build.templates)

      grunt.log.writeln """
        You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
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
          You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
          Should still work, but you should change it to uRequire/grunt-urequire
          version v0.3 and above.

          Transformed @data is:
          #{JSON.stringify @data, null, ' '}
        """


      ### The 'real' grunt-urequire task ###
      if @target[0] isnt '_' # check its not a derived/default, staring with _

        done = @async()
        @data.done = dataDone = do(taskName=@target)->
          (doneVal)->
            if doneVal is true
              grunt.log.ok "grunt-urequire task '#{taskName}' is done(:-)"
            else
              grunt.log.error "grunt-urequire task '#{taskName}' has errors ):-("
            done doneVal
            #@todo:1,5 add 'done' to uRequireCOnfig - store it from @data{} first,
            #call it before this done()

        gruntDeriveReader = (derive)->
            if _.isString derive
              if cfgObject = grunt.config.get("urequire.#{derive}") # @todo: support root level grunt objects (eg RequireJs) using '/' ?
                cfgObject
              else
                if cfgObject = require _fs.realpathSync derive      # @todo: test `require` is using butter-require within uRequire :-)
                  cfgObject
                else
                  grunt.log.error """
                    Error loading configuration files:
                      derive '#{derive}' not found in grunt's config, nor is a valid filename
                      while processing derive array ['#{config.derive.join "', '"}']"
                    """
                  dataDone false
            else
              if _.isPlainObject derive
                derive
              else
                grunt.log.error """
                  Error loading configuration files:
                    Unknown derive :\n #{derive}
                    while processing derive array ['#{config.derive.join "', '"}']
                  """
                dataDone false

        #init our grunt-urequire with 3 configs:
        configs = [
          # grunt's data under current @target
          @data

          # assume '_defaults' if no `derive`s exist on current @target
          if _.isUndefined(@data.derive) and grunt.config.get("urequire._defaults")
              {derive: '_defaults'}
          else
            {}

          # add @target as default `bundleName` if its missing
          {bundleName: @target}
        ]

        bb = new urequire.BundleBuilder configs, gruntDeriveReader
        bb.buildBundle()
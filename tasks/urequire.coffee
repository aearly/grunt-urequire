# Supporting uRequire ver >=0.3.0
"use strict"

urequire = require 'urequire'

module.exports = (grunt) ->

  _ = grunt.util._

  grunt.registerMultiTask "urequire", "Convert javascript modules using uRequire", ->

    ### DEPRECATED OLD FORMAT CONFIG ###
    # detect old format's 'options':
    if (@target is 'options') and (_.any grunt.config.get("urequire"), (val, key)-> key in urequire.Build.templates)

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

        configParams = []

        gatherDeriveConfigs = (config)->
          if _.isObject config # better safe that sorry
            configParams.push config

            if config.derive
              config.derive = [config.derive] if not _.isArray(config.derive) #convert '_myDefault' to ['_myDefault']

              # add all derived objects to configParams
              for drv in config.derive # drv is the label eg 'myDerived'
                if cfgObject = grunt.config.get("urequire.#{drv}") #todo: support root level grunt objects (eg RequireJs) using '/' ?
                  gatherDeriveConfigs cfgObject  #recurse
                else
                  grunt.log.error "derive '#{drv}' not found in grunt's config, while processing derive array ['#{config.derive.join "', '"}']"
                  dataDone false

        gatherDeriveConfigs @data # grunt's data under current @target

        # assume '_defaults' if no `derive`s exist on current @target
        gatherDeriveConfigs {derive: '_defaults'} if _.isUndefined @data.derive


        # add @target as default `bundleName` if its missing
        configParams.push {bundle: bundleName: @target}

        # using 'new' with `apply` http://stackoverflow.com/questions/1606797/use-of-apply-with-new-operator-is-this-possible
        configParams.unshift null # needed as 1st item for `new` & `apply` below
        bb = new (Function.prototype.bind.apply urequire.BundleBuilder, configParams)

        bb.buildBundle()
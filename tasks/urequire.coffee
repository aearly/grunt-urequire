# Supporting grunt 0.4.x & uRequire ver 0.4.x/0.5.x/0.6.x
"use strict"
fs = require 'fs'
path = require 'path'
urequire = require 'urequire'
_B = require 'uberscore'

urequire.gruntTask = {targets:{}} # a place to store grunt-urequire info & a bundleBuilder for each @target is stored in `targets`

module.exports = (grunt) ->
  _ = grunt.util._
  # Register *once*, on a 'watch' event, to populate a `filesWatch` array:
  #   filesWatch = ['file1', 'file2', 'file1', 'file3', 'file4']
  grunt.verbose.writeln "grunt-urequire: Registering grunt.event.on 'watch' once"
  grunt.event.on 'watch', (action, file)->
    if (_.any urequire.gruntTask.targets, (target)-> target.filesWatch) # any target with filesWatch ?
      for target, targetHash of urequire.gruntTask.targets
        grunt.verbose.writeln "grunt-urequire: watch adding '#{file}' to target = '#{target}' filesWatch."
        targetHash.filesWatch.push file # assume all targetHash have a [], flushed when they are used to build
      delete urequire.gruntTask.filesWatch1st #dont need that anymore, only 1st time
    else # grunt urequire tasks have not run yet - we dont know how many there are coming through!
      grunt.verbose.writeln "grunt-urequire: 1st watch events batch, adding to filesWatch1st: '#{file}'"
      (urequire.gruntTask.filesWatch1st or= []).push file

  if (not urequire.VERSION) or (urequire.VERSION < '0.6.0')
    grunt.fail.warn """
      Wrong uRequire version #{urequire.VERSION || '"<0.6.0"'}
      grunt-urequire 0.6.x requires urequire ">=v0.6.0".
    """
  else
    grunt.verbose.writeln "grunt-urequire: registerMultiTask 'urequire' once"
    grunt.registerMultiTask "urequire", "Convert nodejs & AMD modules using uRequire", ->
      if @target[0] isnt '_' #  ignore derived @target's(those staring with `_`, eg `_defaults`)
        targetRunCount = (urequire.gruntTask.targets[@target]?.runCount || 0) + 1
        _B.setp urequire.gruntTask.targets, "#{@target}.runCount", targetRunCount, {overwrite:true, separator:'.'}

        # a little cover of grunt @async()
        taskRunDone = _.once do(taskName = @target, targetRunCount, done = @async())-> #make sure we run async()
          (doneVal)->
            b = bundleBuilder.build
            secs = (new Date() - b.startDate) / 1000
            if (doneVal is true) or (doneVal is undefined)
              grunt.log.ok "grunt-urequire: task '#{taskName}' ##{targetRunCount} is done in #{secs} secs (:-)"
            else
              grunt.log.error "grunt-urequire: task '#{taskName}' ##{targetRunCount} took #{secs} secs and has errors ):-(" +
                if b.watch then "NOT QUITING because of watch!)" else ''

            # dont halt grunt watch when errors occured
            done if b.watch then true else doneVal

        # for our @target, create a bundleBuilder (if not already there) using configs derived from grunt's @data
        if not bundleBuilder = urequire.gruntTask.targets[@target]?.bundleBuilder
          grunt.verbose.writeln "grunt-urequire: initializing bundleBuilder for task @target = '#{@target}'"

          # Cater for DEPRECATED OLD FORMAT CONFIG (uRequire ~v2.9)
          if (@target is 'options') and (_.any grunt.config.get("urequire"), (val, key)-> key in urequire.Build.templates)
            grunt.log.writeln """
              grunt-urequire: You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
              Should still work, but you should change it to uRequire/grunt-urequire
              version v0.3 and above.

              Ignoring bogus 'options' task.
            """
            taskRunDone true
            return
          else
            # detect old format & transform it to the new
            if @target in urequire.Build.templates and grunt.config.get("urequire.options")
              @data = _.clone @data, true
              _.extend @data, grunt.config.get("urequire.options")
              @data.template = @target
              grunt.log.writeln """
                grunt-urequire: You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
                Should still work, but you should change it to uRequire/grunt-urequire
                version v0.3 and above.

                Transformed @data is:
                #{JSON.stringify @data, null, ' '}
              """

            # The 'real' grunt-urequire task, for uRequire >=0.4.0
            @data.done = taskRunDone
            # a derive reader reads from grunt config, as well as files
            # @todo: fix file relative positions in deriveReader
            gruntDeriveReader = (derive)->
              if _.isString derive
                if cfgObject = grunt.config.get("urequire.#{derive}") # @todo: support root level grunt objects (eg RequireJs) using '/' ?
                  cfgObject
                else
                  if cfgObject = require fs.realpathSync derive       # @todo: try/catch & test `require` is using butter-require within uRequire :-)
                    cfgObject
                  else
                    grunt.log.error """
                      grunt-urequire: Error loading configuration files:
                        derive '#{derive}' not found in grunt's config, nor is a valid filename
                        while processing derive array ['#{config.derive.join "', '"}']"
                      """
                    taskRunDone false
              else
                if _.isPlainObject derive
                  derive
                else
                  grunt.log.error """
                    grunt-urequire: Error loading configuration files:
                      Unknown derive :\n #{derive}
                      while processing derive array ['#{config.derive.join "', '"}']
                    """
                  taskRunDone false

            # init our grunt-urequire with 3 configs:
            configs = [
              @data # grunt's data under current @target

              #assume '_defaults'
              if _.isUndefined(@data.derive) and grunt.config.get "urequire._defaults"
                {derive: '_defaults'}
              else {}

              {bundle:name: @target}  # @target as default `bundle.name` if its missing
            ]

            bundleBuilder = new urequire.BundleBuilder configs, gruntDeriveReader
            _B.setp urequire.gruntTask.targets, "#{@target}.bundleBuilder", bundleBuilder, {overwrite:true, separator:'.'}
            # end setting up bundleBuilder for @target

        # run a build, when we have a bundleBuilder
        if bundleBuilder and bundleBuilder.bundle and bundleBuilder.build
          # setup out taskRunDone for each consequtive invocation
          bundleBuilder.build.done = taskRunDone

          # check nightWatch :-)
          # have we accumulated 'watch' events / files that need to be refreshed ?
          if not filesWatch = urequire.gruntTask.targets[@target]?.filesWatch #not for task @target
            filesWatch = urequire.gruntTask.filesWatch1st

          if not _.isEmpty filesWatch
            changedFiles = _.map (_.unique filesWatch), (file)-> # accept only unique files
              path.relative bundleBuilder.bundle.path, file      # with cwd being `bundle.path`

            grunt.verbose.writeln "grunt-urequire: @target = '#{@target}', changed files relative to bundle.path='#{bundleBuilder.bundle.path}' :\n", changedFiles
            urequire.gruntTask.targets[@target].filesWatch = [] # reset filesWatch - considered as processed
            bundleBuilder.build.watch = 'grunt-urequire'
            bundleBuilder.buildBundle changedFiles

          else # empty filesWatch - why ?
            if (not filesWatch) # undefined, means we' arent watching at all (no filesWatch1st, nor @target's)
              grunt.verbose.writeln "grunt-urequire: full build, no watching!"
              bundleBuilder.buildBundle()
            else
              grunt.log.writeln "grunt-urequire: IGNORING BOGUS grunt call:no watched files were changed! ? Use debounceDelay: x000 ?"
              taskRunDone false # task SHOULDN'T have been called, but just finish it

        else # should never occur
          grunt.log.error "grunt-urequire: Error - bundleBuilder is NOT initialized for @target '#{@target}'"
          taskRunDone false # task SHOULDN'T have been called, but just finish it
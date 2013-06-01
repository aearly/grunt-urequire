# Supporting uRequire ver 0.4.0alpha0
"use strict"
fs = require 'fs'
path = require 'path'
urequire = require 'urequire'
_B = require 'uberscore'

urequire.gruntTask = {} # a place to store bundleBuilder & other @target related info

module.exports = (grunt) ->
  _ = grunt.util._

  # Register *once*, on a 'watch' event, to populate a `filesWatch` object:
  #      filesWatch = {
  #        # added: [ 'file1', 'file2', 'file1'] # not checking uniqueness
  #        # deleted: ['file3', 'file4']
  #        all: ['file1', 'file2', 'file1', 'file3', 'file4']
  #      }
  if not urequire.gruntTask.isWatchSet # register only once (grunt-watch 0.4.3 error)?
    urequire.gruntTask.isWatchSet = true
    grunt.verbose.writeln "uRequire: Registering grunt.event.on 'watch'"

    grunt.event.on 'watch', (action, file)->
      grunt.verbose.writeln file + ' has ' + action
      urequire.gruntTask.filesWatch or= {}
#      fwActionFiles = urequire.gruntTask.filesWatch[action] or= []
#      fwActionFiles.push file
      fwAllFiles = urequire.gruntTask.filesWatch['all'] or= []
      fwAllFiles.push file

  # register once, a grunt multiTask
  if not urequire.gruntTask.isMultiTaskSet # register only once
    urequire.gruntTask.isMultiTaskSet = true
    grunt.verbose.writeln "uRequire: registerMultiTask 'urequire'"

    grunt.registerMultiTask "urequire", "Convert javascript modules using uRequire", ->
      if @target[0] isnt '_' #  ignore derived @target's(those staring with `_`, eg `_defaults`)
        targetRunCount = (urequire.gruntTask?[@target]?.runCount || 0) + 1
        _B.setValueAtPath urequire.gruntTask, "#{@target}.runCount", targetRunCount, true, '.'

        # a little cover of grunt @async()
        taskRunDone = _.once do(taskName = @target, targetRunCount, done = @async())-> #make sure we run async()
          (doneVal)->
            if (doneVal is true) or (doneVal is undefined)
              grunt.log.ok "grunt-urequire task '#{taskName}' ##{targetRunCount} is done(:-)"
            else
              grunt.log.error "grunt-urequire task '#{taskName}' ##{targetRunCount} has errors ):-(" +
                if bundleBuilder.build.watch then "grunt-urequire NOT QUITING because of watch!" else ''

            # dont halt grunt watch when errors occured
            done if bundleBuilder?.build?.watch then true else doneVal

        # for our @target, create a bundleBuilder (if not already there) using configs derived from grunt's @data
        if not bundleBuilder = urequire.gruntTask?[@target]?.bundleBuilder
          grunt.verbose.writeln "uRequire: initializing bundleBuilder for task target '#{@target}'"

          #Cater for DEPRECATED OLD FORMAT CONFIG (uRequire ~v2.9)

          # detect old format's 'options':
          if (@target is 'options') and (_.any grunt.config.get("urequire"), (val, key)-> key in urequire.Build.templates)
            grunt.log.writeln """
              You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
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
                You are using a *DEPRACATED* grunt-urequire format in your gruntfile.
                Should still work, but you should change it to uRequire/grunt-urequire
                version v0.3 and above.

                Transformed @data is:
                #{JSON.stringify @data, null, ' '}
              """

            # The 'real' grunt-urequire task, for uRequire >=0.4.0alpha

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
                      Error loading configuration files:
                        derive '#{derive}' not found in grunt's config, nor is a valid filename
                        while processing derive array ['#{config.derive.join "', '"}']"
                      """
                    taskRunDone false
              else
                if _.isPlainObject derive
                  derive
                else
                  grunt.log.error """
                    Error loading configuration files:
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

              {bundleName: @target}  # @target as default `bundleName` if its missing
            ]

            bundleBuilder = new urequire.BundleBuilder configs, gruntDeriveReader
            _B.setValueAtPath urequire.gruntTask, "#{@target}.bundleBuilder", bundleBuilder, true, '.' # todo: uBerscore 0.9 --> {forceCreate: true, separator: '.'}
            # end setting up bundleBuilder for @target

        # run a build, when we have a bundleBuilder
        if bundleBuilder
          # setup out taskRunDone for each consequtive invocation
          bundleBuilder.build.done = taskRunDone

          # check nightWatch :-)
          filesWatch = urequire.gruntTask.filesWatch
          if not _.isEmpty filesWatch   # we have a 'watch' event and files that need to be refreshed

            changedFiles = _.map (_.unique filesWatch.all), (file)-> # accept only unique files
              path.relative bundleBuilder.bundle.path, file          # with cwd being `bundle.path`

            grunt.verbose.writeln "grunt-urequire: changedFiles= \n", changedFiles
            urequire.gruntTask.filesWatch = {} # reset filesWatch - considered as processed

            bundleBuilder.build.watch = 'grunt-urequire'
            bundleBuilder.buildBundle changedFiles
          else
            if not filesWatch # undefined filewatch means we' arent watching at all
              bundleBuilder.buildBundle() # full build
            else
              grunt.log.writeln "grunt-urequire: IGNORING BOGUS call, while watching: no watched files were changed!"
              taskRunDone true # task SHOULDN'T have been called, but just finish it

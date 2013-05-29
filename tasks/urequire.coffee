# Supporting uRequire ver 0.4.0alpha0
"use strict"
fs = require 'fs'
path = require 'path'
urequire = require 'urequire'
_B = require 'uberscore'

urequire.gruntTask = {} # a place to store bundleBuilder & other @target related info

module.exports = (grunt) ->
  _ = grunt.util._

  # Register once on each a 'watch' event, popoluate a `filesWatch` object:
  #      filesWatch = {
  #        added: [ 'file1', 'file2']
  #        deleted: ['file3', 'file4']
  #      }
  if not urequire.gruntTask.isWatchSet # register only once (grunt-watch 0.4.3 error)?
    urequire.gruntTask.isWatchSet = true
    grunt.verbose.writeln "uRequire: Registering grunt.event.on 'watch'"

    grunt.event.on 'watch', (action, filepath)->
      grunt.verbose.writeln filepath + ' has ' + action
      urequire.gruntTask.filesWatch or= {}
      fwActionFiles = urequire.gruntTask.filesWatch[action] or= []
      if filepath not in fwActionFiles
        fwActionFiles.push filepath

  # register once, a grunt multiTask
  if not urequire.gruntTask.isMultiTaskSet # register only once
    urequire.gruntTask.isMultiTaskSet = true
    grunt.verbose.writeln "uRequire: registerMultiTask 'urequire'"

    grunt.registerMultiTask "urequire", "Convert javascript modules using uRequire", ->
      if @target[0] isnt '_' # ignore a derived/default (those staring with `_`, eg `_defaults`)
        targetRunCount = (urequire.gruntTask?[@target]?.runCount || 0) + 1
        _B.setValueAtPath urequire.gruntTask, "#{@target}.runCount", targetRunCount, true, '.'

        # a little cover of grunt @async()
        taskRunDone = do(taskName = @target, targetRunCount, done = @async())-> #make sure we run async()
          (doneVal)->
            if (doneVal is true) or (doneVal is undefined)
              grunt.log.ok "grunt-urequire task '#{taskName}' ##{targetRunCount} is done(:-)"
            else
              grunt.log.error "grunt-urequire task '#{taskName}' ##{targetRunCount} has errors ):-("
            done doneVal  #@todo:1,5 add 'done' to uRequireCOnfig - store it from @data{} first,
                            #          and call it before this done() ?

        # create out bundleBuilder, using configs derived from grunt's @data
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

              # assume '_defaults' if no `derive`s exist on current @target
              ({derive: '_defaults'} if _.isUndefined(@data.derive) and grunt.config.get "urequire._defaults") || {}

              # @target as default `bundleName` if its missing
              {bundleName: @target}
            ]

            bundleBuilder = new urequire.BundleBuilder configs, gruntDeriveReader
            _B.setValueAtPath urequire.gruntTask, "#{@target}.bundleBuilder", bundleBuilder, true, '.' # todo: uBerscore 0.9 --> {forceCreate: true, separator: '.'}
            # end setting up bundleBuilder for @target

        # run this always
        # setup out taskRunDone for each consequtive invocation
        bundleBuilder.build.done = taskRunDone

        #check if nightWatch :-) found some files
        filesWatch = urequire.gruntTask.filesWatch
        if not _.isEmpty filesWatch   # we have a 'watch' event and files that need to be refreshed
          grunt.verbose.writeln "watch event with filesWatch = \n", filesWatch
          changedFiles = _.unique _.reduce filesWatch, #    {action1:[file1, ...], action2:[file2, ...]}
              (allfiles, files, action) ->       # to ['file1', 'file2', ...]
                for file in files
                  allfiles.push path.relative bundleBuilder.bundle.bundlePath, file # @todo: test on windows, mixing *nix & windows paths
                allfiles
            , []
          grunt.verbose.writeln "urequire: changedFiles= \n", changedFiles
          urequire.gruntTask.filesWatch = {} # reset filesWatch - considered as processed

          bundleBuilder.build.watch = 'grunt-urequire'
          bundleBuilder.buildBundle changedFiles
        else
          bundleBuilder.buildBundle()

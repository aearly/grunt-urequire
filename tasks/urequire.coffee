# Supporting grunt 0.4.x & uRequire >=0.6.11
"use strict"
fs = require 'fs'
path = require 'path'
urequire = require 'urequire'
_B = require 'uberscore'
l = new _B.Logger 'grunt-urequire'

urequire.targets = {} 

pkg = JSON.parse fs.readFileSync path.join __dirname, '../package.json'

module.exports = (grunt) ->
  _ = grunt.util._
  # Register *once*, on a 'watch' event, to populate a `filesWatch` array:
  #   filesWatch = ['file1', 'file2', 'file1', 'file3', 'file4']
  grunt.verbose.writeln "grunt-urequire v#{pkg.version}: Registering grunt.event.on 'watch' once"
  grunt.event.on 'watch', (action, file)->
    if (_.any urequire.targets, (target)-> target.filesWatch) # any target with filesWatch ?
      for target, targetHash of urequire.targets
        grunt.verbose.writeln "grunt-urequire: watch adding '#{file}' to target = '#{target}' filesWatch."
        targetHash.filesWatch.push file # assume all targetHash have a [], flushed when they are used to build
      delete urequire.filesWatch1st #dont need that anymore, only 1st time
    else # grunt urequire tasks have not run yet - we dont know how many there are coming through!
      grunt.verbose.writeln "grunt-urequire: 1st watch events batch, adding to filesWatch1st: '#{file}'"
      (urequire.filesWatch1st or= []).push file

  if (not urequire.VERSION) or (urequire.VERSION < '0.6.11')
    grunt.fail.warn """
      Wrong uRequire version #{urequire.VERSION || '"<0.6.11"'}
      grunt-urequire 0.6.11 requires urequire ">=v0.6.11".
    """
  else
    grunt.verbose.writeln "grunt-urequire v#{pkg.version}: registerMultiTask 'urequire' once"
    grunt.registerMultiTask "urequire", "Convert nodejs & AMD modules using uRequire", ->
      if @target[0] isnt '_' #  ignore derived @target's(those staring with `_`, eg `_defaults`)
        targetRunCount = (urequire.targets[@target]?.runCount || 0) + 1
        _B.setp urequire.targets, "#{@target}.runCount", targetRunCount, {overwrite:true, separator:'.'}

        # a little cover of grunt @async()
        taskRunDone = _.once do(taskName = @target, targetRunCount, done = @async())-> #make sure we run async()
          (doneVal)->
            b = bundleBuilder.build
            secs = (new Date() - b.startDate) / 1000
            if (doneVal is true) or (doneVal is undefined)
              grunt.log.ok "grunt-urequire v#{pkg.version} : task '#{taskName}' ##{targetRunCount} is done in #{secs} secs (:-)"
            else
              grunt.log.error "grunt-urequire v#{pkg.version} : task '#{taskName}' ##{targetRunCount} took #{secs} secs and has errors ):-(" +
                if b.watch then "NOT QUITING because of watch!)" else ''

            # dont halt grunt watch when errors occured
            done if b.watch then true else doneVal

        # for our @target, create a bundleBuilder (if not already there) using configs derived from grunt's @data
        if bundleBuilder = urequire.targets[@target]?.bundleBuilder        
          l.warn "grunt-urequire v#{pkg.version} : already have a bundleBuilder for task @target = '#{@target}'"
        else
          grunt.verbose.writeln "grunt-urequire v#{pkg.version} : initializing bundleBuilder for task @target = '#{@target}'"
          @data.done = taskRunDone                  
          gruntDeriveLoader = (derive)-> # load from grunt config, file if not found
            if _.isString derive
              if cfgObject = grunt.config.get("urequire.#{derive}") # @todo: support root level grunt objects (eg RequireJs) using '/' ?
                cfgObject
              else
                try  # @todo: fix file relative positions in deriveReader
                  cfgObject = require fs.realpathSync derive
                catch er      # @todo: try/catch & test `require` is using butter-require within uRequire :-)
                if cfgObject
                  cfgObject
                else
                  grunt.log.error """
                    grunt-urequire: Error loading configuration files:
                      derive '#{derive}' not found in grunt's config, nor is a valid filename
                    """
                  taskRunDone false
            else
              if _B.isHash derive
                derive
              else
                grunt.log.error """
                  grunt-urequire: Error loading configuration files:
                    Unknown derive :\n #{derive}
                  """
                taskRunDone false

            # init our grunt-urequire with 3 configs:
          configs = [            
            @data # grunt's data under current @target                        
            if (_B.isHash(@data) and _.isUndefined(@data.derive))
              grunt.config.get("urequire._defaults") 
            {bundle: name: @target} # @target as default `bundle.name`
          ]
          bundleBuilder = new urequire.BundleBuilder configs, gruntDeriveLoader
          _B.setp urequire.targets, "#{@target}.bundleBuilder", bundleBuilder, {overwrite:true, separator:'.'}
          
        # run a build, when we have a bundleBuilder
        if bundleBuilder and bundleBuilder.bundle and bundleBuilder.build
          # setup out taskRunDone for each consequtive invocation
          bundleBuilder.build.done = taskRunDone

          # check nightWatch :-)
          # have we accumulated 'watch' events / files that need to be refreshed ?
          if not filesWatch = urequire.targets[@target]?.filesWatch #not for task @target
            filesWatch = urequire.filesWatch1st

          if not _.isEmpty filesWatch
            changedFiles = _.map (_.unique filesWatch), (file)-> # accept only unique files
              path.relative bundleBuilder.bundle.path, file      # with cwd being `bundle.path`

            grunt.verbose.writeln "grunt-urequire: @target = '#{@target}', changed files relative to bundle.path='#{bundleBuilder.bundle.path}' :\n", changedFiles
            urequire.targets[@target].filesWatch = [] # reset filesWatch - considered as processed
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
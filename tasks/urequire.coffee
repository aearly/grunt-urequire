minUrequireVersion = "0.7.0-beta6" # Supporting grunt 0.4.x & uRequire >=0.7.0

fs = require 'fs'
path = require 'path'
_B = require 'uberscore'
l = new _B.Logger 'grunt-urequire'

try
  urequire = require 'urequire'
catch err
  l.err "You 'll need `npm install urequire` (version >- 0.7.0) already installed with your project - urequire is only a `peerDependencies` of `grunt-urequire`.\n", err
  throw err

pkg = JSON.parse fs.readFileSync path.join __dirname, '../package.json'
if require('compare-semver').lt urequire.VERSION, [minUrequireVersion]
  throw "`urequire` version >= '#{minUrequireVersion}' is needed for `grunt-urequire` v'#{pkg.version}'"

filesWatch1st = null

module.exports = (grunt) ->
  _ = grunt.util._
  urequire.grunt or= grunt

  gruntDeriveLoader = _.memoize (derive)-> # load from grunt config, or file if not found
    if _.isString derive
      if cfgObject = grunt.config.get("urequire.#{derive}") # @todo: support root level grunt objects (eg RequireJs) using '/' ?
        cfgObject
      else
        try           # @todo: fix file relative positions in deriveReader
          cfgObject = require fs.realpathSync derive
        catch er
        if cfgObject
          cfgObject
        else
          throw new Error """
            grunt-urequire: Error loading configuration files:
            derive '#{derive}' not found in grunt's config, nor is a valid filename
            """
    else
      if _B.isHash derive
        derive
      else
        throw new Error """
          grunt-urequire: Error loading configuration files: Unknown derive :\n #{l.prettify derive}
          """

  grunt.verbose.writeln "grunt-urequire v#{pkg.version}: Registering grunt.event.on 'watch' once"
  grunt.event.on 'watch', (action, file)->
    if (_.any urequire.BBExecuted, (bb)-> bb.filesWatch) # any bb with filesWatch ?
      filesWatch1st = null #dont need that anymore, only 1st time
      for bb in urequire.BBExecuted
        grunt.verbose.writeln "grunt-urequire: adding to filesWatch of bundleBuilder.build.target = '#{bb.build.target}': '#{file}'"
        bb.filesWatch.push file #  all bbs have a filesWatch = []  before they build
    else # grunt urequire tasks have not run yet - we dont know how many there are coming through!
      grunt.verbose.writeln "grunt-urequire: 1st watch events batch, adding to filesWatch1st: '#{file}' "
      (filesWatch1st or= []).push file

  grunt.verbose.writeln "grunt-urequire v#{pkg.version}: registerMultiTask 'urequire' once"
  grunt.registerMultiTask "urequire", "Convert nodejs & AMD modules using uRequire", ->
    if @target[0] isnt '_' #  ignore derived @target's(those staring with `_`, eg `_defaults`)
      # for our @target, create a bundleBuilder (if not already there) using configs derived from grunt's @data
      if bundleBuilder = urequire.findBBExecutedLast @target
        grunt.verbose.writeln "grunt-urequire v#{pkg.version}: already has a bundleBuilder for task @target = '#{@target}'"
      else
        grunt.verbose.writeln "grunt-urequire v#{pkg.version}: initializing bundleBuilder for task @target = '#{@target}'"

        configs = [ # init our grunt-urequire with 4 configs:
          {build: target: @target}                    # @target is mandatory `build.target`
          @data                                       # grunt's data under current @target
          if (_B.isHash(@data) and _.isUndefined(@data.derive))
            grunt.config.get("urequire._defaults")    #__defaults if no other derive, if it exists
          grunt.config.get("urequire._all")           # _all if exists. undefined is fine
        ]
        bundleBuilder = new urequire.BundleBuilder configs, gruntDeriveLoader # stores target

      # run a build, when we have a bundleBuilder
      if bundleBuilder and bundleBuilder.bundle and bundleBuilder.build
        # have we accumulated 'watch' events / files that need to be refreshed ?
        if not filesWatch = bundleBuilder.filesWatch
          filesWatch = filesWatch1st # might be null, or have changed files

        if not _.isEmpty filesWatch
          changedFiles = _.map (_.unique filesWatch), (file)-> # accept only unique files
            path.relative bundleBuilder.bundle.path, file      # with cwd being `bundle.path`
          grunt.verbose.writeln "grunt-urequire: executing a partial build for @target = '#{@target}', changed files relative to bundle.path='#{bundleBuilder.bundle.path}' :\n", changedFiles
          bundleBuilder.filesWatch = [] # reset filesWatch on BB for next time
          _.extend bundleBuilder.build.watch, {enabled: true, info: 'grunt-urequire'}

        gruntDone = @async()
        gruntStart = new Date()
        grunt.verbose.writeln "Executing a full build for @target `#{@target}`" if not changedFiles
        bundleBuilder.buildBundle(changedFiles).then(
          (bb)=>
            grunt.log.ok "grunt-urequire v#{pkg.version}: task '#{@target}' build ##{bundleBuilder.build.count} done in #{(new Date() - gruntStart) / 1000} secs (:-)"
            gruntDone true

          (errors)=>
            grunt.log.error errors if not _.size errors
            grunt.log.error "grunt-urequire v#{pkg.version}: task '#{@target}' build ##{bundleBuilder.build.count} took #{(new Date() - gruntStart) / 1000} secs and has #{_.size errors} errors ):-(" +
              (if bundleBuilder?.build?.watch.enabled is true then "NOT QUITING because of watch!)" else '')
            gruntDone bundleBuilder?.build?.watch.enabled
        )
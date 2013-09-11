# grunt-urequire 0.6.0
==============

Grunt wrapper for [uRequire](https://github.com/anodynos/uRequire), version >= v0.6.0

*Requires grunt 0.4.x*

## Features

### config objects

uRequire [config objects](http://urequire.org/masterdefaultsconfig.coffee#config-usage) can become grunt tasks, as-is from the file format.

### Watching

You can use `grunt-contrib-watch` v0.5.x watch task to invoke a partial build of changed files only.

Important notes:

  * **You DO need** `watch: xxx: options: nospawn: true` (or `spawn: false` on newer versions). This allows uRequire to use the already loaded bundle/modules information for rapid builds of only changed files.

  * You DONT need `urequire: xxx: build: watch: true`

  * Each `watch` event is a *partial build*. The first time a partial build is carried out, a full build is automatically performed instead. **You don't need (and shouldn't) perform a full build** before running the watched task (i.e dont run the `urequire:xxx` grunt task before running `watch: xxx: tasks: ['urequire:xxx']`). A full build is always enforced by urequire to make sure everything is loaded and temp files of 'combined' almond builds are in place.

## Examples

### Simple example

Example config (using the uRequire >= v0.4.0 format) :

```javascript

    urequire:{
      myLibAsUMD: {
        template: "UMD", // default, can be ommited
        path: "lib/",
        dstPath: "umdLib"
      },

      myLibCombinedToWorkEverywhere: {
        template:'combined',
        path: "lib/",
        main: 'myLibraryMain-Index',
        dstPath: "combinedLib.js"
      },

      _defaults: {
        debugLevel:90,
        verbose: true,
        scanAllow: true,
        allNodeRequires: true,
        noRootExports: false
      }
    }
```

* Note the new format - version 1.x grunt-urequire format should still be supported, but DEPRECATED.*

### uBerscore Example

A more involved example (in coffeescript), taken from [uBerscore](http://github.com/anodynos/uBerscore).

Its also using `grunt-contrib-watch` to watch and build changed files as needed (partial build).

```coffeescript
    ### NOTE: uRequire config is used as a testbed & example, thus so many comments :-) ###
    urequire:
                                                   # @note any urequire task starting with '_' is ignored as grunt target
                                                   # and only used for `derive`-ing.
      _defaults:                                   # These are the defaults, when a task has no 'derive' at all.
        bundle:                                    # Use `derive:[]` to skip deriving it.
          path: "#{sourceDir}"
          filez: [/./, '!**/draft/*.*', '!uRequireConfig*']
          copy: [/./, '**/*.*']                    # 2 ways to say "I want all non-`resource` matched filez to be copied to build.dstPath"

          dependencies:
            node: 'util'                           # 'util' will not be added to deps array, will be available only on nodejs execution.
                                                   # Same as 'node!myDep', but allows module to run on nodejs without conversion
            exports: bundle:
              ['lodash', 'agreement/isAgree']      # simple syntax: depsVars infered from dep/variable bindings of bundle or other known sources
              #'lodash': ['_']                     # precise syntax: deps & their corresponding vars
              #'agreement/isAgree': ['isAgree', 'isAgree2']

          resources: [                             # define some Resource Converters
            [                                      # example: declare an RC to perform some 'concat/inject' job.
              '~+inject:VERSION'                   # note: '+' sets `isBeforeTemplate` flag: this RC runs AFTER our Module's code is parsed
                                                   #           and its information is extracted/adjusted - right BEFORE running the template.
                                                   #           This RC type enables you do manipulate the body & dependencies (it runs on Modules only).
                                                   #           The m.converted IS NOT considered at this stage - we are dealing with AST code & Module dependencies only.
              ['uberscore.coffee']                 # note: '~' in name means `isMatchSrcFilename:true` - matching `uberscore.coffee`, instead of dstFilename `uberscore.js`
                                                   # inject 'var VERSION=xxx' before the module's body code
              (modyle)->
                modyle.beforeBody =                # m.afterBody also exists
                  "var VERSION='#{pkg.version}';"  # inject any text (no need to be parseable code)
            ]                                      # no convFilename needed
          ]

        build:
          debugLevel: 0                            # 0 is default
          verbose: false                           # false is default

                                                   # a simple UMD build
      UMD:
        #'build':                                  # `build` and `bundle` hashes are not needed - keys are safelly recognised, even if they're not in them.
        #'derive': ['_defaults']                   # not needed - by default it deep uDerives all '_defaults'. To avoid use `derive:[]`.
        #template: 'UMD'                           # Not needed - 'UMD' is default
        dstPath: "#{buildDir}"                     # all files converted files are written here
        resources: [                               # example: perform some 'concat' job, AFTER the template conversion is done.
          [ '!banner:uberscore.js',                # '!' means 'isAfterTemplate: true'
            'concat/add banner to uberscore.js'    # some description
            ['uberscore.js']                       # note we are looking to change the dstFilename `uberscore.js` (not `uberscore.coffee`). We could have used ~ to match srcFilename
            (r)->"#{banner}\n#{r.converted}"       # @converted holds our converted UMD code, since this RC runs AFTER the template conversion
          ]                                        # no convFilename needed
        ]
                                                   # a 'combined' build, - works with or without AMD loaders
      dev:                                         # on Web & nodejs as a plain `<script>` or `require('dep')`
        template: 'combined'
        main: 'uberscore'                          # template: 'combined' requires a 'main' module.
                                                   # if 'main' is missing, then main is assumed to be `bundleName`,
                                                   # which in turn is assumed to be grunt's @target ('dev' in this case).
                                                   # Having 'dev' as the bundle.name/main, but no module by that name (or 'index' or 'main')
                                                   # will cause a compilation error. Its better to be precise anyway, in case this config is used outside grunt :-)
        dstPath: './build/dist/uberscore-dev.js'   # the name of a file instead of a directory is needed for 'combined'


                                                   # A 'combined' & minified build, that is `derive`d from 'dev' (& specifically '_defaults') that :
                                                   # - uses re.js/uglify2 for minification.
                                                   # - removes code, based on code 'skeletons'
      min:
        derive: ['dev', '_defaults']               # need to specify we also need '_defaults', in this order.
        dstPath: './build/dist/uberscore-min.js'
        optimize: 'uglify2'                        # doesn't have to be a String. `true` selects 'uglify2' also. It can also be 'uglify'.
                                                   # Even more interestingly, u can pass any 'uglify2' (or 'uglify') keys,
                                                   # the r.js way (https://github.com/jrburke/r.js/blob/master/build/example.build.js)
                                                   # eg optimize: {uglify2: output: beautify: true}
        filez: ['!blending/deepExtend.coffee']     # leave this file out (`filez` inherits its parent's `filez`, adding this spec)
        resources: [
          [
            '+remove:debug/deb & deepExtend'       # An RC with the `isBeforeTemplate` '+' flag, runs ONLY on Modules

            [/./]                                  # All filez considered

            (m)->                                  # `convert` function, passing a Module instance as the only argument
              m.replaceCode c for c in [           # replace with nothing (i.e delete whole expression/statement)
                'if (l.deb()){}'                   # any code that matches these code skeletons
                'if (this.l.deb()){}'              # Eg it matches `if (l.deb(30)){statement1;statement2;...}`
                'l.debug()'                        # It MUST BE a valid Javascript String OR
                'this.l.debug()']                  # an AST sub-tree object (only present keys are compared) - see esprima/Mozila AST parser specification

                                                   # Remove `deepExtend` from this build
              if m.dstFilename is 'uberscore.js'   # Since this RC runs on all Modules, limit to this one for efficiency
                m.replaceCode {
                  type: 'Property',                # remove property/key `deepExtend: ...` from 'uberscore.js'
                  key:
                    type: 'Identifier'
                    name: 'deepExtend'
                }

                m.replaceDep 'blending/deepExtend' # actually remove dependency from all (resolved) arrays (NOT THE AST CODE).
          ]
                                                   # With `isBeforeTemplate` rcs you can also :
                                                   #   modyle.injectDeps {'deps/dep1': ['depVar1', 'depVar2'], ....}
                                                   #   modyle.replaceDep 'types/type', 'types/myType'
        ]
        debugLevel: 0
                                                   # uRequire-ing the specs: we also have two builds as 'UMD' &
      spec:                                        # as 'combined'
        derive: []                                 # disable derive-ing from '_defaults'
        path: "#{sourceSpecDir}"
        copy: [/./]
        dstPath: "#{buildSpecDir}"
        dependencies: exports: bundle:             # declaratively inject these dependencies on all modules
          chai: 'chai'
          lodash: '_'
          'uberscore': '_B'
          'spec-data': 'data'
        debugLevel: 0

      specCombined:
        derive: ['spec']                           # deep inherits all of 'spec' BUT none of '_defaults':-)
        dstPath: "#{buildSpecDir}_combined/index-combined.js"
        template: 'combined'
        #main: 'index'                             # not needed: if `bundle.main` is undefined it defaults to `bundle.bundleName`
                                                   # or 'index' or 'main' (whichever found 1st as a module on bundleRoot)
                                                   # with the price of a warning! In spec's case, THERE IS a module
                                                   # 'index.coffee' which is picked (with the price of a warning).

      ### Examples showing off uRequire ###

      fileConfig:                                  # EXAMPLE: how to reference (& `derive`-ing from) external urequire config file(s)
        derive: [
          'source/code/uRequireConfig.coffee']     # note: not deriving at all from '_defaults', unless its specified.
        template: 'UMD'                            # overriding some of its parent options
        dstPath: 'build/UMDFileConfigBuild'        # Its effectivelly equivalent to issuing:
                                                   #  `$ urequire config source/code/uRequireConfig.coffee -o ./build/UMDFileConfigBuild -t UMD`

      Logger:                                      # EXAMPLE: building only a sub-tree of the whole bundle.
        #main: 'Logger'                            # Not needed: bundle.main & consequently bundle.name inherit grunt's task/target 'Logger' name
        template: 'combined'                       # We build only 'Logger' (& its dependencies) in a 'combined' build.
        dependencies: exports: root: 'Logger':'_L' # export the module on `window._L`, with a `noConflict()` baked in
        optimize: true
        dstPath: 'build/Logger-min.js'             # @todo: Its ineffiecient in urequire 0.6, cause ALL modules are converted to AMD first,
                                                   #        and then used as input to rjs.optimize which picks only dependent ones.
                                                   #        Future urequire versions should fix this.


      UMDreplaceDep:                               # EXAMPLE: replace a bundle dependency with another, perhaps a mock
        derive: ['UMD', '_defaults']               # derive from these two configs
        dstPath: "build/UMDreplaceDep"             # save to this destination path
        resources: [
                                                   # first, create our hypothetical mock out of an existing module
          [ "rename to 'types/isHashMock.js'",     # a title with default flags
            ['types/isHash.js']                    # our RC.filez is self descriptive :-)
            undefined                              # undefined `convert()` function - we only need to change the filename
            'types/isHashMock.js'                  # convFilame is a String: the `dstFilename` will change to that, # and all modules
          ]                                        # in bundle know this resource/module by its new name


          [ "+replace dependency 'types/isHash'"   # `isBeforeTemplate` flag '+', running on Modules only, just before the Template is applied
            [/./]                                  # run all on all matching `bundle.filez` (in all modules due to `isBeforeTemplate`)
            (m)-> m.replaceDep(                    # call `m.replaceDep`
              'types/isHash',                      # passing old & new dep
              'types/isHashMock')                  # in `bundleRelative` format
          ]
        ]

      AMDunderscore:                               # EXAMPLE: replace a global dependency, whether existing in module code
        template: 'AMD'
        dstPath: "build/AMDunderscore"
        dependencies: exports: bundle:             # defaults have a ['lodash',..]` - it will complain lodash about var binding,
          'lodash': '_'                            # so use the '{dep: 'varName'} format
        resources: [
          [ "+replace 'lodash' with 'underscore'"  # although we inject 'lodash' in each module, change it here
            [/./]
            (m)->m.replaceDep(                     # note: `module.replaceDep` replaces all deps - even injected dependencies in modules
              'lodash',                            # via `depenencies.exports.bundle` like lodash in this example.
              'underscore')                        # The exception is 'combined' template, cause deps are NOT injected in modules
          ]                                        # (they are available through closure). So you need to change
        ]                                          # `depenencies.exports.bundle` to inject the right ones instead of `replaceDep`-ing them

      UMDunderscore:
        derive: ['AMDunderscore', '_defaults']
        template: 'UMD'
        dstPath: "build/UMDunderscore"

      nodejsCompileAndCopy:                        # EXAMPLE: marking as Resources, changing behaviors
        template: 'nodejs'
        filez: ['uRequireConfig*.*']
        dstPath: "build/nodejsCompileAndCopy"
        resources: [
                                                   # EXAMPLE: compile a .coffee to .js, but dont treat it as a Module
          [ "#~markAsTextResource"                 # marking a .coffee as 'TextResource' ('#' flag) is enough to compile as .js,
            ["uRequireConfig.coffee"]              # but exclude it from becoming a Module (i.e no UMD/AMD template is applied)
          ]

          [                                        # read file content, alter it & save under different name
            "@markAsFileResource"                  # Mark as a FileResource - its content is not read on refresh
            ["uRequireConfig_UMDBuild.json"]       # matching `filez` for this RC is just one file
            (r)->                                  # `convert()` function
              content = '\n' + r.read()            # calling read() on the resource read its content, using @srcFilename within `bundle.path`
              r.save('changedBundleFileName.json', # save() under a different name (relative to bundle.path) & changed content
                content)
          ]
        ]

    watch:
      UMD:
        files: ["#{sourceDir}/**/*.*", "#{sourceSpecDir}/**/*.*"]  # note: new subdirs dont work - https://github.com/gruntjs/grunt-contrib-watch/issues/70
        tasks: ['urequire:UMD' , 'urequire:spec', 'mocha', 'run']

      dev:
        files: ["#{sourceDir}/**/*.*", "#{sourceSpecDir}/**/*.*"]
        tasks: ['urequire:dev', 'urequire:specCombined', 'concat:specCombinedFakeModule', 'mochaDev', 'run']

      min:
        files: ["#{sourceDir}/**/*.*", "#{sourceSpecDir}/**/*.*"]
        tasks: ['urequire:min', 'urequire:specCombined', 'concat:specCombinedFakeModuleMin', 'mochaDev', 'run']

      options:
        spawn: false    # WARNING: urequire watch works ONLY with `spawn: false` (or nospawn:true in older versions)
        #atBegin: true  # atBegin NOT WORKING: watch is not registered & __temp gets deleted.
                        # Also occasional bug with grunt-watch causes constant rerun of tasks when mocha has errors

    concat:
      'specCombinedFakeModule':
        options: banner: '{"name":"uberscore", "main":"../../../dist/uberscore-dev.js"}'
        src:[]
        dest: 'build/spec_combined/node_modules/uberscore/package.json'

      'specCombinedFakeModuleMin':
        options: banner: '{"name":"uberscore", "main":"../../../dist/uberscore-min.js"}'
        src:[]
        dest: 'build/spec_combined/node_modules/uberscore/package.json'

```

Look for more documentation on [uRequire.org](http://uRequire.org)'s docs.
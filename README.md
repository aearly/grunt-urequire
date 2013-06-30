# grunt-urequire 0.4.5
==============

Grunt wrapper for [uRequire](https://github.com/anodynos/uRequire), version >= v0.4.0

*Requires grunt 0.4.x*

## Features

### config objects

uRequire [config objects](http://urequire.org/urequireconfigmasterdefaults.coffee#config-usage) can become grunt tasks, as-is from the file format.

### Watching

You can use `grunt-contrib-watch` watch task to invoke a partial build of changed files only.

Notes:

  * You need `watch: xxx: options: nospawn: true`.

  * You DONT need `urequire: xxx: build: watch: true`

  * At each `watch` event there is a *partial build* carried out.

  For non-`combined`-templates you are advised to have a full build run before watch (eg run the `urequire:xxx` grunt task before running `watch: xxx: tasks: ['urequire:xxx']`) within the same invocation of grunt. For example run `grunt urequire:xxx watch:xxx`) so that all modules & their dependencies are loaded.

  For `combined` template builds, a full build is enforced the 1st time by urequire and you SHOULD NOT have run the task before the watch - i.e just use `grunt watch:myCombinedBuildWatchTask` where `watch: myCombinedBuildWatchTask: tasks: ['urequire:myCombinedBuild']`.

## Examples

### Simple example

Example config (using the new uRequire >= v0.4.0 format) :

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

    ###
      uRequire config for uBerscore is used as a testbed & example, thus so many comments :-)
    ###
    urequire:
      # These are the defaults, when a task has no 'derive' at all. Use derive:[] to skip deriving it.
      # @note that any urequire task starting with '_' is ignored as a grunt target and only used for `derive`-ing.
      # @todo: On derive: a) allow dropping of cyclic references. b) fix file reference paths ALWAYS being relative to the initial path (the path used for 1st file), instead of file referencing.
      _defaults:
        bundle:
          path: "#{sourceDir}"
          filez: ['**/*.*', '!**/draft/*.*', '!uRequireConfig*']
          copy: [/./]
          resources: [                           # example: declaring resource converter to perform some 'concat/inject' job.
            [ '*inject VERSION to uberscore.js', # inject the VERSION variable inside the module's code, BEFORE running the template
              ['uberscore.js']  # note we are looking to change the converted `uberscore.js` (not `uberscore.coffee`)
              (source)-> """var VERSION = '#{ pkg.version }'; //injected by urequire resource\n
                            #{source}"""
              # no dstFilename converter needed
            ]
          ]
          dependencies:
            node: 'util'   # 'util' will not be added to deps array, will be available only on nodejs execution. Same as 'node!myDep'
            exports:
              bundle:   # ['lodash', 'agreement/isAgree'] # simple syntax
                'lodash':"_",                             # precise syntax
                'agreement/isAgree': 'isAgree'

        build:
          verbose: false # false is default
          debugLevel: 40 # 0 is default
#          continue: true

      # a simple UMD build
      uberscoreUMD:
        #'build': # `build` and `bundle` hashes are not needed - keys are safelly recognised, even if they're not in them.
        #'derive': ['_defaults'] # not needed - by default it deep uDerives all '_defaults'. To avoid use `derive:[]`.
          #template: 'UMD' # Not needed - 'UMD' is default
          dstPath: "#{buildDir}"

          resources: [ # example: perform some 'concat' job.
            [ '*!concat/add banner to uberscore.js', # '!' means 'isAfterTemplate: true'
              ['uberscore.js']                       # note we are looking to change the dstFilename `uberscore.js` (not `uberscore.coffee`)
              (source, srcFilename)->"#{banner}\n#{source}"
              #no dstFilename converter needed
            ]
          ]

      # a 'combined' build, that also works without AMD loaders on Web
      uberscoreDev:
        main: 'uberscore' # Tempalte 'combined' requires a 'main' module.
                          # if 'main' is missing, then main is assumed to be `bundleName`,
                          # which in turn is assumed to be grunt's @target ('uberscoreDev' in this case).
                          # Having 'uberscoreDev' as the bundleName/main, but no module by that name (or 'index' or 'main')
                          # will cause a compilation error.
                          # Its better to be precise anyway, in case this config is used outside grunt.

        dstPath: './build/dist/uberscore-dev.js'
        template: 'combined'

      # A combined build, that is `derive`d from 'uberscoreDev' (& specifically '_defaults')
      # that uses re.js/uglify2 for minification.
      uberscoreMin:
        derive: ['uberscoreDev', '_defaults'] # need to specify we also need '_defaults', in this order.
        dstPath: './build/dist/uberscore-min.js'
        optimize: 'uglify2' # doesn't have to be a String. `true` selects 'uglify2' also. It can also be 'uglify'.
                            # Even more interestingly, u can pass any 'uglify2' (or 'uglify') keys,
                            # the r.js way (https://github.com/jrburke/r.js/blob/master/build/example.build.js)
                            # eg optimize: {uglify2: output: beautify: true}

      # An example on how to reference (`derive`-ing from) external urequire config file(s),
      # while overriding some of its options.
      #
      # @note its not deriving at all from '_defaults', unless its specified.
      #
      # Its effectivelly equivalent to issuing
      #  `$ urequire config source/code/uRequireConfig.coffee -o ./build/code -t UMD`
      uberscoreFileConfig:
        derive: ['source/code/uRequireConfig.coffee']
        template: 'UMD'
        dstPath: 'build/anotherUMDBuild'

      # An example of building only a sub-tree of the whole bundle.
      # Here we want to build only Logger (& its dependencies) in a 'combined' build using almond.
      # So we need `main: 'Logger'`, which is infered from grunt task/target name
      # @todo: Its somewhat ineffiecient in urequire 0.4, cause all modules are converted to AMD, used as input to rjs.optimize
      # which only picks the dependent ones. Future urequire version should fix this.
      Logger: # bundle.main & consequently bundle.name inherit task/target 'Logger' name
        template: 'combined'
        optimize: true
        dstPath: 'build/Logger-min.js'

      # uRequire-ing the specs: we also have two build as 'UMD' & as 'combined'
      spec: # deep inherits all '_defaults', by default :-)
        path: "#{sourceSpecDir}"
        copy: [/./, '**/*.*'] # 2 ways to say "I want all non-resource files to be coiped to build.dstPath"
        dstPath: "#{buildSpecDir}"
        dependencies:
          exports: bundle:
            chai: 'chai'
            lodash: '_'
            uberscore: '_B'
            'spec-data': 'data'
            # assert = chai.assert # @todo(for uRequire 4 5 5) allow for . notation to refer to export!

      specCombined:
        derive: ['spec'] # deep inherits all of 'spec' BUT none of '_defaults':-)
        dstPath: "#{buildSpecDir}_combined/index-combined.js"
        template: 'combined'
        #main: 'index' # not needed: if `bundle.main` is undefined it defaults
                       # to `bundle.bundleName` or 'index' or 'main' (whichever found 1st as a module on bundleRoot)
                       # with the price of a warning! In spec's case, THERE IS a module 'index.coffee' which is picked.
        dependencies:
          depsVars:
            uberscore: ['_B', 'uberscore']

    watch:
      urequireDev:
        files: ["#{sourceDir}/**/*.*", "#{sourceSpecDir}/**/*.*" ] # new subdirs dont work - https://github.com/gruntjs/grunt-contrib-watch/issues/70
        tasks: ['urequire:uberscoreDev'] #, 'urequire:spec', 'mocha']
        options: nospawn: true

```

Look for more documentation on [uRequire.org](https://uRequire.org)'s docs (WIP).
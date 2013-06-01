grunt-urequire
==============

Grunt wrapper for [uRequire](https://github.com/anodynos/uRequire), version >= 0.3.0beta1

Example config (using the new uRequire > v0.3.0beta1 format) :
```javascript
    urequire:{
      myLibAsUMD: {
        template: "UMD", // default, can be ommited
        path: "lib/",
        outputPath: "umdLib"
      },

      myLibCombinedToWorkEverywhere: {
        template:'combined',
        path: "lib/",
        main: 'myLibraryMain-Index',
        outputPath: "combinedLib.js"
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

A more involved example (in coffeescript), taken from [uBerscore](http://github.com/anodynos/uBerscore).

```coffeescript
    urequire:
      # These are the defaults, when a task has no 'derive' at all. Use derive:[] to skip deriving it.
      # @note that any urequire task starting with '_' is ignored as a grunt target and only used for `derive`-ing.
      # @note On `derive`: a) dont use cyclic references. b) file referenced path is ALWAYS relative to the initial path (the path used for 1st file/grunt config), instead of the file referencing the referenced one. Both will be fixed :-)
      _defaults:
        bundle:
          path: "/source/code"
          ignore: [/^draft/, 'uRequireConfig_UMDBuild.json', 'uRequireConfig.coffee'] # completelly ignore these
          dependencies:
            exports: bundle: #['lodash', 'agreement/isAgree'] # simple syntax
              'lodash':"_",                               # precise syntax
              'agreement/isAgree': 'isAgree'
            noWeb: ['util']
        build:
          verbose: false # false is default
          debugLevel: 0  # 0 is default

      # a simple UMD build
      uberscoreUMD:
        #'build': # `build` and `bundle` hashes are not needed - keys are safelly recognised, even if they're not in them.
        #'derive': ['_defaults'] # not needed - by default it deep uDerives all '_defaults'. To avoid use `derive:[]`.
          #template: 'UMD' # Not needed - 'UMD' is default
          outputPath: "./build/code"



      # a 'combined' build, that also works without AMD loaders on Web
      uberscoreDev:
        main: 'uberscore' # if 'main' is missing, then main is assumed to be `bundleName`,
                          # which in turn is assumed to be grunt's @target ('uberscoreDev' in this case).
                          # Having 'uberscoreDev' as the bundleName/main, but no module by that name (or 'index' or 'main')
                          # will cause a compilation error. Its better to be precise anyway, in case this config is used outside grunt.

        outputPath: './build/dist/uberscore-dev.js'
        template: 'combined'

      # A combined build, that is `derive`d from 'uberscoreDev' (& specifically '_defaults')
      # that uses re.js/uglify2 for minification.
      uberscoreMin:
        derive: ['uberscoreDev', '_defaults'] # need to specify we also need '_defaults', in this order.
        outputPath: './build/dist/uberscore-min.js'
        optimize: 'uglify2' # doesn't have to be a String. `true` selects 'uglify2' also. It can also be 'uglify'.
                            # Even more interestingly, u can pass any 'uglify2' keys,
                            # the r.js way (https://github.com/jrburke/r.js/blob/master/build/example.build.js)
                            # eg {optimize: uglify2: output: beautify: true}

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
        outputPath: 'build/anotherUMDBuild'

      # uRequire-ing the specs: we also have two build as 'UMD' & as 'combined'
      spec: # deep inherits all '_defaults', by default :-)
        path: "source/spec"
        outputPath: "build/spec"
        dependencies:
          exports: bundle:
            chai: 'chai'
            lodash: '_'
            uberscore: '_B'
            'spec-data': 'data'
            # assert = chai.assert # @todo(for uRequire 4 5 5) allow for . notation to refer to export!

      specCombined:
        derive: ['spec'] # deep inherits all of 'spec' BUT none of '_defaults':-)
        outputPath: "build/spec_combined/index-combined.js"
        template: 'combined'
        #main: 'index' # not needed: if `bundle.main` is undefined it defaults
                       # to `bundle.bundleName` or 'index' or 'main' (whichever found 1st as a module on bundleRoot)
                       # with the price of a warning! In spec's case, THERE IS a module 'index.coffee' which is picked.
        dependencies:
          variableNames:
            uberscore: ['_B', 'uberscore']
```

Look for more documentation on [uRequire](https://github.com/anodynos/uRequire)'s docs (WIP)
grunt-urequire
==============

Grunt wrapper for [uRequire](https://github.com/anodynos/uRequire), version >= 0.3

Example config (using the new uRequire v0.3.x format) :

    urequire:{
      myLibAsUMD: {
        template: "UMD", // default, can be ommited
        bundlePath: "lib/",
        outputPath: "umdLib"
      },

      myLibCombinedToWorkEverywhere: {
        template:'combined',
        bundlePath: "lib/",
        main: 'myLibraryMain-Index',
        outputPath: "combinedLib.js"
      },

      _defaults: {
        debugLevel:90,
        verbose: true,
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false
      }
    }

* Note the new format - version 1.x grunt-urequire format is still supported, but DEPRECATED.*
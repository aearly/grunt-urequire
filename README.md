grunt-urequire
==============

Grunt wrapper for uRequire, version >= 0.3

Example config:

    grunt.initConfig({
      urequire: {
        UMD: {
          bundlePath: "lib/",
          outputPath: "umdLib/"
        },
        options: {
          scanAllow: true,
          allNodeRequires: true,
          noExports: true,
          verbose: true,
          Continue: false,
          webRootMap: "lib/"
        }
      }
    });

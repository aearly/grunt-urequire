
grunt-urequire
==============

Grunt wrapper for uRequire


Example config:

    grunt.initConfig({
      urequire: {
        umd: {
          bundlePath: "lib/",
          outputPath: "umdLib/"
        },
        amd: {
          bundlePath: "lib/",
          outputPath: "amdLib/"
        },
        options: {
          scanAllow: true,
          allNodeRequires: true,
          verbose: true,
          Continue: false,
          webRootMap: "lib/"
        }
      }
    });

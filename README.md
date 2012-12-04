
grunt-urequire
==============

Grunt wrapper for uRequire


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

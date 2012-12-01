module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    lint: {
      files: ["lib/**/*.js"]
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true,
        es5: true
      },
      globals: {}
    },
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
    /*browserify: {
      "dist/bundle.js": {
        requires: ["traverse"],
        aliases: ["jquery:jquery-browserify"],
        entries: ["src/*.js"],
        prepend: ["<banner:meta.banner>"],
        append: [],
      }
    }*/
  });

  // Load task.
  grunt.loadTasks("../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

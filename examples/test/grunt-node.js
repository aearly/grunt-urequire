module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      nodejs: {
        bundlePath: "lib/",
        outputPath: "nodeLib/"
      },
      options: {
        scanAllow: true,
        allNodeRequires: true,
        noExports: true,
        verbose: true,
        Continue: false
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

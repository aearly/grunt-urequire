module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      AMD: {
        bundlePath: "lib/",
        outputPath: "amdLib/"
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

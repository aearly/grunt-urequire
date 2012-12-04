module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      UMD: {
        bundlePath: "lib/",
        outputPath: "umdLib/"
      },
      options: {
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false,
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

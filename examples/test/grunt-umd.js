module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      UMD: { // using the old DEPRECATED v0.1.x format
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
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

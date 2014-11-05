module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      UMD: { // using the old DEPRECATED v0.1.x format
        path: "lib",
        outputPath: "build/umdLib"
      },
      _defaults: {
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false,
        verbose: true,
        webRootMap: "lib/"
      }
    }
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

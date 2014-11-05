module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      AMD: {
        path: "lib/",
        outputPath: "build/amdLib"
      },
      _defaults: {
        scanAllow: true,
        allNodeRequires: true,
        noExports: true,
        verbose: true,
        continue: false,
        webRootMap: "lib/"
      }
    }
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: { // using the old DEPRECATED v0.1.x format
      nodejs: {
        path: "lib/",
        outputPath: "build/nodeLib"
      },
      _defaults: {
        scanAllow: true,
        allNodeRequires: true,
        noExports: true,
        verbose: true,
        continue: false
      }
    }
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

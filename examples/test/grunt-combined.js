module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      _defaults: {
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false,
        debugLevel: 40,
        verbose: true
      },

      myCombinedLib: {
        template:'combined', // using the new v0.3.x format
        path: "lib/",
        main: 'A',
        outputPath: "combinedLib.js"
      }
    }
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

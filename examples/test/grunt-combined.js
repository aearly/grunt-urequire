module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      combined: {
        template:'combined', // using the new v0.3.x format
        bundlePath: "lib/",
        main: 'A',
        outputPath: "combinedLib.js",
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false,
        debugLevel:90,
        verbose: true
      }
    }
  });

  // Load task.
  grunt.loadTasks("../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

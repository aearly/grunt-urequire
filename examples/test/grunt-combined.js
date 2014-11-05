module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    urequire: {
      _defaults: {
        scanAllow: true,
        allNodeRequires: true,
        rootExports: false,
        //debugLevel: 40,
        verbose: true
      },

      myCombinedLib: {
        template:'combined',
        path: "lib/",
        main: 'A',
        optimize: 'uglify2',
        outputPath: 'build/combinedLib-min.js'
      }
    }
  });

  // Load task.
  grunt.loadTasks(__dirname + "/../../tasks");

  // Default task.
  grunt.registerTask("default", "urequire");

};

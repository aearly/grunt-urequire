module.exports = function (grunt) {
  grunt.initConfig({
    mocha: {
      src: ["test/*.test.js"]
    },

    coffee: {
      compile: {
        files: {
          "tasks/*.js": "tasks/*.coffee"
        }
      }
    }
  });


  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadTasks("test/task");
  grunt.registerTask("default", "coffee mocha");
};

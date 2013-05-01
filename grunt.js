module.exports = function(grunt) {
  grunt.initConfig({
    simplemocha: {
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
  grunt.loadNpmTasks("grunt-simple-mocha");
  grunt.loadTasks("test/task");
  return grunt.registerTask("default", ["coffee", "simplemocha"]);
};
module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      src: ["test/*.test.js"]

    coffee:
      compile:
        files:
          "tasks/*.js": "tasks/*.coffee"

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadTasks    "test/task"
  grunt.registerTask "default", ["coffee", "simplemocha"]
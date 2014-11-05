module.exports = (grunt) ->

  grunt.initConfig
    simplemocha:
      options:
        timeout: 7000
      src: ["test/*.test.js"]

  grunt.registerTask "default", ["simplemocha"]
  grunt.loadTasks    "test/task"
  grunt.loadNpmTasks "grunt-simple-mocha"


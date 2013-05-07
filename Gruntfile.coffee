module.exports = (grunt) ->
  grunt.initConfig
    simplemocha:
      src: ["test/*.test.js"]

    coffee:
      compile:
        files:
          "tasks/urequire.js": "tasks/urequire.coffee"

#          @todo: NOT WORKING - WHY ? https://github.com/gruntjs/grunt-contrib-coffee
#          expand: true
#          cwd: 'tasks/'
#          src: ['**/*.coffee']
#          dest: 'tasks/'
#          ext: '.js'

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadTasks    "test/task"
  grunt.registerTask "default", ["coffee", "simplemocha"]
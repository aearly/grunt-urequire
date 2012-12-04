module.exports = function (grunt) {
  grunt.initConfig({
    lint: {
      files: ["tasks/*.js", "test/*.js", "examples/**/lib/*.js", "examples/**/grunt*.js"]
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true,
        es5: true,
        strict: false
      },
      globals: {
        define: true,
        describe: true,
        it: true
      }
    },
    mocha: {
      src: ["test/*.test.js"]
    },
    watch: {
      files: "<config:lint.files>",
      tasks: "default"
    }
  });

  grunt.loadTasks("test/task");
  grunt.registerTask("default", "lint mocha");
};

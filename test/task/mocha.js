module.exports = function (grunt) {

  var path = require('path'),
    Mocha = require('mocha');

  grunt.registerMultiTask('mocha', 'Run unit tests with mocha.', function () {
    var options = {},
      paths,
      filepaths = grunt.file.expandFiles(this.file.src);
    grunt.file.clearRequireCache(filepaths);
    paths = filepaths.map(path.resolve);

    options.growl = true;
    options.reporter = "spec";
    options.timeout = 8000;

    mocha_instance = new Mocha(options);
    paths.map(mocha_instance.addFile.bind(mocha_instance));
    mocha_instance.run(this.async());
  });

  function resolveFilepaths(filepath) {
    return path.resolve(filepath);
  }

};

(function() {
  "use strict";

  var urequire, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require("lodash");

  urequire = require('urequire');

  module.exports = function(grunt) {
    return grunt.registerMultiTask("urequire", "Convert javascript modules using uRequire", function() {
      /* DEPRECATED OLD FORMAT CONFIG
      */

      var bb, done, _ref;
      if ((this.target === 'options') && (_.any(grunt.config.get("urequire"), function(val, key) {
        return __indexOf.call(urequire.Build.templates, key) >= 0;
      }))) {
        return grunt.log.writeln("You are using a *deprecated* grunt-urequire format in your gruntfile.\nShould still work, but you should change it to uRequire/grunt-urequire version v0.3 and above.\n\nIgnoring bogus 'options' task.");
      } else {
        if ((_ref = this.target, __indexOf.call(urequire.Build.templates, _ref) >= 0) && grunt.config.get("urequire.options")) {
          this.data = _.clone(this.data, true);
          _.extend(this.data, grunt.config.get("urequire.options"));
          this.data.template = this.target;
          grunt.log.writeln("You are using a *deprecated* grunt-urequire format in your gruntfile.\nShould still work, but you should change it to uRequire/grunt-urequire version v0.3 and above.\n\nTransformed @data is:\n" + (JSON.stringify(this.data, null, ' ')));
        }
        /* The 'real' grunt-urequire task
        */

        done = this.async();
        this.data.done = function(doneVal) {
          if (doneVal === true) {
            grunt.log.ok('grunt-urequire task is done()');
          }
          return done(doneVal);
        };
        bb = new urequire.BundleBuilder(this.data, grunt.config.get("urequire._defaults"), {
          bundle: {
            bundleName: this.target
          }
        });
        return bb.buildBundle();
      }
    });
  };

}).call(this);

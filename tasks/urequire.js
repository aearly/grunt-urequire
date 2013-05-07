(function() {
  "use strict";
  var urequire, _fs,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _fs = require('fs');

  urequire = require('urequire');

  module.exports = function(grunt) {
    var _;

    _ = grunt.util._;
    return grunt.registerMultiTask("urequire", "Convert javascript modules using uRequire", function() {
      /* DEPRECATED OLD FORMAT CONFIG
      */

      var bb, configs, dataDone, done, gruntDeriveReader, _ref;

      if ((this.target === 'options') && (_.any(grunt.config.get("urequire"), function(val, key) {
        return __indexOf.call(urequire.Build.templates, key) >= 0;
      }))) {
        return grunt.log.writeln("You are using a *DEPRACATED* grunt-urequire format in your gruntfile.\nShould still work, but you should change it to uRequire/grunt-urequire\nversion v0.3 and above.\n\nIgnoring bogus 'options' task.");
      } else {
        if ((_ref = this.target, __indexOf.call(urequire.Build.templates, _ref) >= 0) && grunt.config.get("urequire.options")) {
          this.data = _.clone(this.data, true);
          _.extend(this.data, grunt.config.get("urequire.options"));
          this.data.template = this.target;
          grunt.log.writeln("You are using a *DEPRACATED* grunt-urequire format in your gruntfile.\nShould still work, but you should change it to uRequire/grunt-urequire\nversion v0.3 and above.\n\nTransformed @data is:\n" + (JSON.stringify(this.data, null, ' ')));
        }
        /* The 'real' grunt-urequire task
        */

        if (this.target[0] !== '_') {
          done = this.async();
          this.data.done = dataDone = (function(taskName) {
            return function(doneVal) {
              if (doneVal === true) {
                grunt.log.ok("grunt-urequire task '" + taskName + "' is done(:-)");
              } else {
                grunt.log.error("grunt-urequire task '" + taskName + "' has errors ):-(");
              }
              return done(doneVal);
            };
          })(this.target);
          gruntDeriveReader = function(derive) {
            var cfgObject;

            if (_.isString(derive)) {
              if (cfgObject = grunt.config.get("urequire." + derive)) {
                return cfgObject;
              } else {
                if (cfgObject = require(_fs.realpathSync(derive))) {
                  return cfgObject;
                } else {
                  grunt.log.error("Error loading configuration files:\n  derive '" + derive + "' not found in grunt's config, nor is a valid filename\n  while processing derive array ['" + (config.derive.join("', '")) + "']\"");
                  return dataDone(false);
                }
              }
            } else {
              if (_.isPlainObject(derive)) {
                return derive;
              } else {
                grunt.log.error("Error loading configuration files:\n  Unknown derive :\n " + derive + "\n  while processing derive array ['" + (config.derive.join("', '")) + "']");
                return dataDone(false);
              }
            }
          };
          configs = [
            this.data, _.isUndefined(this.data.derive) && grunt.config.get("urequire._defaults") ? {
              derive: '_defaults'
            } : {}, {
              bundleName: this.target
            }
          ];
          bb = new urequire.BundleBuilder(configs, gruntDeriveReader);
          return bb.buildBundle();
        }
      }
    });
  };

}).call(this);

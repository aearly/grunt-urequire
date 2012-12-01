var _ = require("lodash");

module.exports = function (grunt) {
	"use strict";

	grunt.registerMultiTask("urequire", "Convert and/or bundle javascript modules using uRequire/UMD", function () {
		var options = {};

		if (this.target === "options") {
			return;
		}

		options.template = this.target.toUpperCase();

		options = _.extend(options, this.data, grunt.config.get("urequire.config"));

		grunt.log.writeln(options);

		require("urequire").processBundle(options);
	});
};




module.exports = function (grunt) {
	"use strict";

	grunt.registerMultiTask("urequire", "Convert and/or bundle javascript modules using uRequire/UMD", function () {
		var options = {};


		require("urequire").processBundle(options);
	});
};


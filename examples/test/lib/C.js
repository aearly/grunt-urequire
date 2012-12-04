var _ = require("underscore");

module.exports = _.map("qwer,asdf,zxvc".split(), function (word, i) {
	return "[" + i + "] " + word;
});

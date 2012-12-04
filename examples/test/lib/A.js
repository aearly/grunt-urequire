define(["underscore"], function (_) {

	return _.map("qwer,asdf,zxvc".split(), function (word, i) {
		return "[" + i + "] " + word;
	});
});

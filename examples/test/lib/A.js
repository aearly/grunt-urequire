define(["underscore", "C"], function (_, C) {

  console.log(C);

	return _.map("qwer,asdf,zxvc".split(), function (word, i) {
		return "[" + i + "] " + word;
	});
});

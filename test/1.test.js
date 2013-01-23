var expect = require("expect.js"),
	exec = require("child_process").exec;


describe("Test project 1:", function () {

	it("should convert to node properly", function (done) {
		exec("grunt --config " + __dirname + "/../examples/test/grunt-node.js", function (err, stdout, stderr) {
      console.log(stderr, stdout, err);
			expect(err).to.equal(null);
			done();
		});
	});

	it("should convert to AMD properly", function (done) {
		exec("grunt --config " + __dirname + "/../examples/test/grunt-amd.js", function (err, stdout, stderr) {
      console.log(stderr, stdout, err);
			expect(err).to.equal(null);
			done();
		});
	});

	it("should convert to umd properly", function (done) {
		exec("grunt --config " + __dirname + "/../examples/test/grunt-umd.js", function (err, stdout, stderr) {
      console.log(stderr, stdout, err);
			expect(err).to.equal(null);
			done();
		});
	});

  it("should convert to 'combined' properly", function (done) {
		exec("grunt --config " + __dirname + "/../examples/test/grunt-combined.js", function (err, stdout, stderr) {
			console.log(stderr, stdout, err);
			expect(err).to.equal(null);
			done();
		});
	});

});

define(function() {
  if (typeof _ === "undefined") {
    return __nodeRequire('underscore');
  } else {
    return _;
  }
});
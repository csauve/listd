require("coffee-script/register");

var listd = require("./lib/listd");
module.exports = listd;

if (!module.parent) {
  var args = process.argv;
  if (args.length != 3) {
    return console.log("Usage: node listd.js <watch-file.ext>")
  }
  listd.run(args[2]);
}
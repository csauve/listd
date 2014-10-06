yaml = require "js-yaml"
fs = require "fs"

module.exports = (contents, callback) ->
  paths = null
  try
    data = yaml.safeLoad(contents)
    paths = traverse data
  catch parseError
    return callback parseError
  callback null, paths

# Convert the structured data into a flat list of paths
traverse = (data, path = []) ->
  paths = []
  if data instanceof Array
    for element in data
      paths = paths.concat traverse element, path
  else if data instanceof Object
    for key, value of data
      newPath = path.slice()
      newPath.push key
      paths = paths.concat traverse value, newPath
  else
    paths.push path.concat data
  return paths
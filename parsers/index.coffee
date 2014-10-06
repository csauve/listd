path = require "path"

# This index is responsible for choosing the right parser module for the file we want to watch.
# It should return null if no parser applies
module.exports = (filePath) ->
  try
    extension = path.extname filePath
    return require "./#{extension.substring 1}"
  catch error
    throw error if error.code != "MODULE_NOT_FOUND"
    return null

fs = require "fs"
reactors = require "../reactors"
parserFor = require "../parsers"
path = require "path"

seenPaths = {}

module.exports.run = (file) ->
  parser = parserFor file
  if not parser
    return console.error "No parser available for #{file}"
  fs.watch file, (event) ->
    if event is "change"
      parseAndReact file, parser
  parseAndReact file, parser

parseAndReact = (file, parse) ->
  fs.readFile file, (readError, contents) ->
    if readError
      return console.error "Error reading #{file}: #{readError.message}"
    parse contents, (parseError, paths) ->
      if parseError
        return console.error "Error parsing #{file}: #{parseError.message}"
      unseenPaths = (path for path in paths when path.join("/") not of seenPaths)

      reactTo unseenPaths for reactTo in reactors
      
      seenPaths = {}
      for path in paths
        seenPaths[path.join("/")] = true

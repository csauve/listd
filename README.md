# listd

An extensible daemon used to watch for and react to changes in structured list files. For example, you keep your todo-list in a .yaml file and want to automatically create events in your calendar or update the status for JIRA issues. listd provides a way to support new file formats with *parsers* and run scripts with *reactors*.

## Usage

To install listd, clone the repository and run `npm install` to get the dependencies. To run listd:

    node ./listd.js /Users/user/Documents/todo.yaml

It can also be run programmatically:

```javascript
var listd = require("listd");
listd.run("/Users/user/Documents/todo.yaml");
```

## Customizing

### Parsers

listd supports YAML files out of the box, but you can add your own parsers to the parsers directory to support additional formats. Use `parsers/index.coffee` to customize how a parser is chosen for a particular file. Currently it will look in the parsers directory for a module named after the file extension.

Parsers can be implemented in coffeescript or javascript, but need to satisfy this interface:

```javascript
module.exports = function(contents, callback) {
  // do some parsing...
  callback(null, [
    ["group 1", "item 1"],
    ["group 2", "subgroup", "item 2"],
    ["group 2", "subgroup", "item 3"],
    ["group 2", "item 4"]
  ]);
};
```

The parser will be called on startup and whenever the watched file is modified. It is given the `contents` of the file and a callback taking arguments `error` and `paths`. It is the responsibility of the parser to parse `contents` into a list of paths, which is just a flattened representation of the file. For example, what the above snippet returns should be the result of parsing this YAML:

```yaml
group 1:
  - item 1

group 2:
  - subgroup:
    - item 2
    - item 3
  - item 4
```

### Reactors

Reactors are modules that are called with a list of unseen paths (what the parsers create) whenever the watched file changes. They must be registered in `reactors/index.coffee`. Every registered reactor will be called when the file changes, so it is the responsibility of the reactors to know what paths are relevant to them. Reactors look like this:

```coffeescript
module.exports = (unseenPaths) ->
  for path in unseenPaths
    parents = path.slice(0, path.length - 1)
    text = path.slice(path.length - 1)[0]

    if "log" in parents and /hello/i.test text
      console.log "hello!"
```

The argument `unseenPaths` is a list of paths that were not present in the last parsing of the file. In this example, "hello!" would be printed when listd parses this YAML file for the first time:

```yaml
log:
  - greetings:
    - say hello
    - say goodbye
```

## Todo

listd is still a work in progress. To be implemented:

* Complete the JIRA reactor
* Implement a Google calendar reactor
* Make it installable as a global command with `npm install -g`
* Support running on multiple files, maybe with different configuration for each?
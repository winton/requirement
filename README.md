# requirement

## Install

```bash
npm install requirement --save
```

## Why index

Generating index files allows you to do a `require` on any directory and get back an object representing the directory structure.

### Example

`cms/index.coffee`:

```coffee
# Generated by `gulp index`.
#
module.exports =
  Editor:
    Article: -> require "./editor/cms.editor.article"
    Header: -> require "./editor/cms.editor.header"
  Header: -> require "./header/cms.header"
  Modals:
    Cropper: -> require "./modals/cms.modals.cropper"
    Embed: -> require "./modals/cms.modals.embed"
    Media: -> require "./modals/cms.modals.media"
    Headers:
      Publish: -> require "./modals/headers/cms.modals.headers.publish"
      Strip: -> require "./modals/headers/cms.modals.headers.strip"
```

Indexing with explicit requires also keeps your project compliant with Browserify compilation.

## Gulp task

The gulp task generates `index.coffee` files in a directory and all subdirectories.

```coffee
gulp = require "gulp"
Task = require("requirement").Task

gulp.task "index", ->
  paths = [
    "#{__dirname}/../../app/scripts"
    "#{__dirname}/../../app2/components"
  ]
  new Task { paths }
```

## Dependency helper

Requiring pieces of your dependency tree is easier with the helper:

```coffee
{ Routes, Components, Stores } = require("requirement") ->
  Routes:     require "."
  Components: require "../../../app/scripts/components"
  Stores:     require "../../../app/scripts/stores"
```

With the explicit requires, we remain compliant with Browserify compilation.

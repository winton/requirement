fs   = require "fs"
path = require "path"

module.exports = class

  constructor: ({ dir, onTree }) ->
    @buildTree { dir, onTree }

  buildTree: ({ dir, onTree, used_names }) ->
    dir          = path.resolve dir
    forbidden    = [ '.json', '.node' ]
    used_names ||= []

    @tree = {}
    files = fs.readdirSync(dir)

    files.forEach (file) =>
      ext   = path.extname   file
      name  = path.basename  file, ext
      fpath = path.join dir, file
      rpath = path.join dir, name

      if fs.lstatSync(fpath).isDirectory()
        file = @classify file
        used_names.push file

        @tree[file] = @buildTree { dir: fpath, used_names, onTree }
        onTree { name: file, @tree, fpath } if onTree
        return
      
      return if forbidden.indexOf(ext) >= 0 or
        !(ext of require.extensions) or
        name == 'index'
      
      name  = @classify(name)
      names = name.split(".")
      child = @tree

      names.forEach (name, i) ->
        if names.length - 1 == i
          child[name] = "require \"#{rpath}\""
        else if used_names.indexOf(name) > -1
          return
        else
          child[name] ||= {}
          child = child[name]

  classify: (string) ->
    regex = /^[a-z]|[_\.][a-z]/g
    string.replace regex, (match) ->
      match.toUpperCase().replace /_/, ""

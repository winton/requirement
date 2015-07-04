fs   = require "fs"
path = require "path"

module.exports = class

  constructor: ({ dir, onTree }) ->
    @buildTree { dir, onTree }

  buildTree: ({ dir, onTree, used_names }) ->
    dir          = path.resolve dir
    forbidden    = [ '.json', '.node' ]
    used_names ||= []

    tree  = {}
    files = fs.readdirSync(dir)

    files.forEach (file) =>
      ext   = path.extname   file
      name  = path.basename  file, ext
      fpath = path.join dir, file
      rpath = path.join dir, name
      used  = used_names.slice()

      if fs.lstatSync(fpath).isDirectory()
        file = @classify file
        used.push file

        tree[file] = @buildTree {
          dir: fpath
          used_names: used
          onTree
        }

        onTree { name: file, tree, fpath } if onTree
        return
      
      return if forbidden.indexOf(ext) >= 0 or
        !(ext of require.extensions) or
        name == 'index'
      
      name  = @classify(name)
      names = name.split(".")
      child = tree

      names.forEach (name, i) ->
        ignore = used.indexOf(name) > -1
        last   = names.length - 1 == i
        req    = "require \"#{rpath}\""
        
        if last && ignore
          tree = req
        else if last
          child[name] = req
        else if ignore
          return
        else
          child[name] ||= {}
          child = child[name]

    tree

  classify: (string) ->
    regex = /^[a-z]|[_\.][a-z]/g
    string.replace regex, (match) ->
      match.toUpperCase().replace /_/, ""

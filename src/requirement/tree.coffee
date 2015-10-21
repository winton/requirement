fs   = require "fs"
path = require "path"

module.exports = class

  constructor: ({ dir, onFinish, onTree }) ->
    name = @classify path.basename dir
    
    tree = {}
    tree[name] = @buildTree { dir, onTree }

    onTree { name, tree, fpath: dir } if onTree
    onFinish() if onFinish

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

        if Object.keys(tree[file]).length == 0
          delete tree[file]
          return

        onTree { name: file, tree, fpath } if onTree
        return
      
      return if forbidden.indexOf(ext) >= 0 or
        !(ext of require.extensions) or
        name == 'index'
      
      name  = @classify(name)
      names = @unique { used, names: name.split(".") }
      child = tree

      names.forEach (name, i) ->
        last = names.length - 1 == i
        
        if last
          child[name] = rpath
        else
          child[name] ||= {}
          child = child[name]

    tree

  classify: (string) ->
    regex = /^[a-z]|[_\.][a-z]/g
    string.replace regex, (match) ->
      match.toUpperCase().replace /_/, ""

  unique: ({ names, used }) ->
    arr = []
    for n in names
      arr.push(n) if used.indexOf(n) == -1
    arr

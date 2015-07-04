coffee = require "js2coffee"
fs     = require "fs"
path   = require "path"
Tree   = require "./tree"

module.exports = class

  constructor: ({ @paths }) ->
    for dir in @paths
      do (dir) => @buildIndices dir

  buildIndices: (dir) ->
    dir = path.resolve dir
    new Tree { dir, @onTree }

  onTree: ({ name, tree, fpath }) ->
    rm = new RegExp fpath, "g"

    out = tree[name]
    out = coffee.build "module.exports = #{JSON.stringify out}"
    out = out.code
    out = out.replace(rm, ".").replace /'/g, ""
    out = out.replace /require/g, "-> require"
    out = """
    # Generated by `gulp index`.
    #
    
    """ + out

    fs.writeFileSync(
      "#{fpath}/index.coffee"
      out
    )

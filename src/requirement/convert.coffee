_         = require "lodash"
Coffee    = require "coffee-script"
js2coffee = require "js2coffee"
fs        = require "fs"
path      = require "path"
Tree      = require "./tree"

module.exports = class

  constructor: ({ @paths }) ->
    for dir in @paths
      do (dir) => @convert dir

  convert: (dir, root=dir) ->
    dir   = path.resolve dir
    files = fs.readdirSync dir

    files.forEach (file) =>
      fpath = path.join dir, file
      
      if fs.lstatSync(fpath).isDirectory()
        @convert fpath, root
      else
        regex   = /[A-Z]\w+\s+=((\s+[A-Z]\w+:){1,}\s+require\s+["\w\.\/]+){1,}/gm
        file    = fs.readFileSync(fpath).toString()
        matches = file.match(regex) || []
        current = matches.map (match) ->
          match = match.replace(/require/g, "")
          match = match.replace(/\s+=/g, ":")
          obj   = Coffee.eval match
        current = _.merge.apply(_, current)

        console.log "current", current

        if current
          requires = @buildRequires root, fpath, current
          requires = JSON.stringify(requires).replace(/\"([^(\")"]+)\":/g,"$1:")

          coffee = js2coffee.build "x = #{requires}"
          coffee = coffee.code.replace "x = ", ""
          coffee = coffee.replace /: '/g, ": require '"

          console.log "coffee", coffee

          index = 0
          file  = file.replace regex, (match) ->
            if index == 0
              coffee
            else
              ""
  
  buildRequires: (dir, fpath, current, future={}) ->
    for key, value of current
      if value instanceof Object
        @buildRequires dir, fpath, value, future
      else
        abs = path.join path.dirname(fpath), value
        abs = abs.replace "#{dir}/", ''

        classes = @pathToClasses abs
        last    = future

        classes.forEach (item, i) ->
          if i == classes.length - 1
            last[item] = value
          else
            last[item] ||= {}
            last = last[item]

    future

  classify: (string) ->
    regex = /^[a-z]|[_\.][a-z]/g
    string.replace regex, (match) ->
      match.toUpperCase().replace /_/, ""

  pathToClasses: (path) ->
    path    = path.replace /\//g, "."
    classes = []

    for klass in path.split(".")
      klass = @classify klass
      classes.push(klass) if classes.indexOf(klass) == -1

    classes

requirement = (fn) ->
  callAllFunctions = (klasses) ->
    obj = {}
    for name, klass of klasses
      if typeof klass == "function"
        obj[name] = klass()
      else
        obj[name] = callAllFunctions klass
    obj

  callAllFunctions fn()

requirement.Task = require "./requirement/task"
module.exports   = requirement

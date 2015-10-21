path = require "path"
{ Convert, Index, Tree } = require "../../lib/requirement"

describe "Requirement", ->
  describe "Tree", ->
    it "works", (done) ->
      dir = path.resolve "spec/fixture"

      new Tree {
        dir
        onFinish: done
        onTree: ({ name, tree, fpath }) ->
          console.log name
          console.log tree
          console.log fpath
          console.log ""
      }

  # describe "Convert", ->
  #   it "works", (done) ->
  #     paths = [ path.resolve "spec/fixture" ]
      
  #     new Convert { paths }

local O = require("src/util/object")

describe("object helper", function ()
  it("creates a simple  object", function ()
    local methods = {
      set = coroutine.wrap(function(state, args)
        state.count = args.value
      end)
    }
    local state = { count = 0 }
    local counter = O.create_object("counter", methods, state)
    counter("set", { value = 5})
    assert.are.same(state.count, 5)
  end)
end)

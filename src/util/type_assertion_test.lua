local T    = require("src/util/type_assertion")

describe("assertions", function ()
  it("detects functions", function ()
    local fn = function ()
      -- NOOP
    end
    assert.has.errors(function() T.is_function(9) end)
    assert.has_no.errors(function() T.is_function(fn) end)
    assert.has_no.errors(function() T.is_function(spy.new(fn)) end)
    assert.has_no.errors(function() T.maybe_function(nil) end)
  end)
end)

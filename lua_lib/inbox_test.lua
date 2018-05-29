local inbox = require "lua_lib/inbox"
local test = require "pl.test"
describe(
  "Busted",
  function()
    it(
      "kind of looks like rspec",
      function()
        assert.are.same({table = "great"}, {table = "no!"})
      end
    )
  end
)

local inbox = require "lua_lib/inbox"

describe("Busted", function()
  it("grabs the last item", function()
    local expected = { channel   = "channel",
                       namespace = "NS",
                       operation = "OP",
                       payload   = "payload" }
    _G.inbox = { index = 1, [1] = expected }

    local result = inbox.fetch()
    assert.are.same(result, expected)
  end)
end
)

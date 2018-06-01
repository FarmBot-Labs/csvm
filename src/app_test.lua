local App   = require("src/app")
local Inbox = require("src/io/inbox")

describe("App", function()
  local stub            = { value = nil }
  local get_message     = spy.new(function ()
    return stub.value
  end)
  local vm = spy.new(function () end)

  it("starts", function ()
    App.run(get_message, vm)
    stub.value = Inbox.new_message(0, "FOO", "BAR")
    App.run(get_message, vm)
    assert.spy(vm).was_called_with("FOO.BAR", match._)
  end)
end)

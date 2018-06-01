local App   = require("src/app")
local Inbox = require("src/io/inbox")

describe("App", function()
  local stub            = { value = nil }
  local get_message     = spy.new(function ()
    return stub.value
  end)
  local message_handler = spy.new(function () end)

  it("starts", function ()
    local app = App.new(get_message, message_handler, {})
    stub.value = Inbox.new_message(0, "FOO", "BAR")
    app("run")
    assert.spy(message_handler).was_called_with("FOO.BAR", match._)
  end)
end)

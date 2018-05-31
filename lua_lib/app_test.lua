local App   = require("lua_lib/app")
local Inbox = require("lua_lib/inbox")

describe("App", function()
  local stub            = { value = nil }
  local get_message     = spy.new(function () end)
  local message_handler = spy.new(function () end)
  local hypervisor      = spy.new(function () end)

  it("starts", function ()
    local app = App.new(get_message, message_handler, hypervisor)
    stub.value = Inbox.new_message(0, "FOO", "BAR")
    app("run")
  end)
end)

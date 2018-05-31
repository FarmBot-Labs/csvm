local OB = require("lua_lib/outbox")

describe("Outbox", function()
  it("replies to messages", function ()
    spy.on(OB, "raw_write")
    OB.reply(0, "FOO", "BAR")
    assert.spy(OB.raw_write).was_called_with("0FOOBAR\r\n")
  end)
end)
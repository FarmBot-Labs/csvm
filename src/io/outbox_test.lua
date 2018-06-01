local OB = require("src/io/outbox")

describe("Outbox", function()
  it("replies to messages", function ()
    spy.on(OB, "raw_write")
    OB.reply(0, 1, 2)
    assert.spy(OB.raw_write).was_called_with("012\r\n")
  end)
end)

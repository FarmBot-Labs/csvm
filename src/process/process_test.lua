local P = require("src/process/process")

describe("Process", function()
  it("initializes defaults", function ()
    local p = P.new({ kind = "sequence", args = {} })
    assert.are.same(p.PC, 2)
    assert.are.same(p.STAT, P.status.OK)
  end)
end)

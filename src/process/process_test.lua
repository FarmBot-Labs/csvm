local P = require("src/process/process")

describe("Process", function()
  it("starts at PC = 1", function ()
    local p = P.new({ kind = "sequence", args = {} })
    assert.are.same(p.PC, 1)
  end)
end)

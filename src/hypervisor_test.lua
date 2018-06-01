local Hypervisor = require("src/hypervisor")

describe("VM", function()
  local hv = Hypervisor.new()
  it("runs `tick`", function()
    assert.has_no.errors(function()
      hv("SYS.TICK") -- Just a noop right now
    end)
  end)
end)

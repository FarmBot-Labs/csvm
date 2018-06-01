local Hypervisor = require("src/hypervisor")
local inbox      = require("src/io/inbox")
describe("VM", function()
  local hv = Hypervisor.new()

  it("crashes on typos", function ()
    assert.has_error(function ()
      hv("NOPE")
    end)
  end)

  it("dumps state", function()
    local copy = hv("SYS.TICK", nil, true) -- Just a noop right now
    assert.are.same(type(copy.id),   "number")
    assert.are.same(type(copy.code), "table")
  end)

  it("saves code for execution later", function()
    local message = inbox.new_message(0, "CODE", "WRITE", "{}")
    local copy    = hv("CODE.WRITE", { message = message }, true)
    assert.are.same(type(copy.id),   "number")
    assert.are.same(type(copy.code[1]), "table")
  end)
end)

local Hypervisor = require("src/hypervisor")
local inbox      = require("src/io/inbox")
local F          = require("src/slicer/fixtures")

describe("VM", function()
  local reply = spy.new(function () end)

  it("crashes on typos", function ()
    local hv    = Hypervisor.new(reply)
    assert.has_error(function ()
      hv({message = inbox.new_message(0, "NO", "NO")})
    end)
  end)

  it("dumps state", function()
    local hv    = Hypervisor.new(reply)
    local copy = hv({
      message = inbox.new_message(0, "SYS", "TICK"),
      copy    = true
    }) -- Just a noop right now
    assert.are.same(type(copy.id),   "number")
    assert.are.same(type(copy.code), "table")
  end)

  it("saves code for execution later", function()
    local hv    = Hypervisor.new(reply)
    local copy =
      hv({ message = inbox.new_message(0, "CODE", "WRITE", "{}"), copy = true })
    assert.are.same(type(copy.id),   "number")
    assert.are.same(type(copy.code["" .. 1]), "table")
  end)

  it("calls PROC.RUN", function()
    local hv    = Hypervisor.new(reply)
    local message1   = inbox.new_message(0, "CODE", "WRITE", F.example1)
    local program_id = hv({ message = message1, copy = true }).id

    local message2   = inbox.new_message(0, "PROC", "RUN", "" .. (program_id))
    local result     = hv({ message = message2, copy = true })
    print(type(result))
  end)
end)

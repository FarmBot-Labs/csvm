local Hypervisor = require("src/hypervisor")
local inbox      = require("src/io/inbox")

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
    })
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
    local state = {
      proc = {},
      id = 1,
      code = { ["1"] = {
          kind = "sequence",
          args = {
            locals = {
              kind = "scope_declaration",
              args = { }
            }
          },
          body = {},
        }
      }
    }
    local hv       = Hypervisor.new(reply, state)
    local message1 = inbox.new_message(0, "PROC", "RUN", "1")
    local result   = hv({ message = message1, copy = false })
    assert.are.same(type(result.proc["2"]), "table")
  end)
end)

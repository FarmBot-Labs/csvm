local M      = {}
local json   = require("lib/json")
local pretty = require("pl.pretty")
local wip    = function () error("Work in progress") end
local T      = require("src/util/type_assertion")
local copy   = require("src/util/deep_copy").deep_copy
local status = require("src/util/deep_copy")

function M.new(reply, inital_state)
  T.is_function(reply)
  T.maybe_table(inital_state)
  local this = inital_state or {
    id   = 0,
    code = {}
  }

  local lookup_table = {
    ["SYS.TICK"]                         = function(_)
      -- TODO: Tick the VM in a round robin.
    end,
    ["CODE.WRITE"]                       = function(a)
      local m = a.message
      this.id            = this.id + 1
      this.code[this.id] = json.decode(m.payload)
      print("Registered code under ID " .. this.id .. ":")
      pretty.dump(this.code[this.id])
      reply(m.channel, status.OK, this.id)
    end,
    ["PROC.RUN"]                         = wip,
    ["PROC.KILL"]                        = wip,
    ["PROC.PAUSE"]                       = wip
  }

  return function(method, args, dump)
    T.maybe_table(args)
    local handler = lookup_table[method]
    if handler then
      handler(args)
    else
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Uknown call '" .. method .. "' sent to hypervisor")
    end

    if dump then
      return copy(this)
    end
  end

end

return M

local M      = {}
local json   = require("lib/json")
local pretty = require("pl.pretty")
local wip    = function () error("Work in progress") end
local T      = require("src/util/type_assertion")

function M.new()
  local this = {
    code_counter = 0,
    code         = {}
  }

  local lookup_table = {
    ["SYS.TICK"]                         = function(_)
      -- TODO: Tick the VM in a round robin.
    end,
    ["CODE.WRITE"]                       = function(a)
      this.code_counter = this.code_counter + 1
      this.code[this.code_counter] = json.decode(a.message.payload)
      print("Registered code under ID " .. this.code_counter .. ":")
      pretty.dump(this.code[this.code_counter])
    end,
    ["PROC.RUN"]                         = wip,
    ["PROC.KILL"]                        = wip,
    ["PROC.PAUSE"]                       = wip
  }

  return function(method, args)
    T.maybe_table(args)
    local handler = lookup_table[method]
    if handler then
      handler(args)
      return
    else
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Uknown call '" .. method .. "' sent to hypervisor")
    end
  end

end

return M

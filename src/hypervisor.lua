local M      = {}
local json   = require("lib/json")
local pretty = require("pl.pretty")
local wip    = function () error("Work in progress") end
local T      = require("src/util/type_assertion")
local copy   = require("src/util/deep_copy").deep_copy
local status = require("src/util/status")
local Proc   = require("src/process/process")

function M.new(reply, inital_state)
  T.is_function(reply)
  T.maybe_table(inital_state)
  local this = inital_state or {
    id   = 0,
    code = {},
    proc = {}
  }

  local lookup_table = {
    ["SYS.TICK"] = function(_)
      -- TODO: Tick the VM in a round robin.
    end,
    ["CODE.WRITE"] = function(a)
      local m = a.message
      this.id                  = this.id + 1
      this.code["" .. this.id] = json.decode(m.payload)
      reply(m.channel, status.OK, this.id)
    end,
    ["PROC.RUN"] = function(a)
      local m = a.message
      local p = this.code[m.payload]
      if p then
        this.id                  = this.id + 1
        this.proc["" .. this.id] = Proc.new(p)
        reply(m.channel, status.OK, "" .. this.id)
      else
        reply(m.channel, status.BAD_CODE_ID, "" .. this.id)
      end
    end,
    ["PROC.KILL"]  = wip,
    ["PROC.PAUSE"] = wip
  }

  return function(args)
    T.maybe_table(args)
    local m       = args.message;
    local method  = m.namespace .. "." .. m.operation
    local handler = lookup_table[method]

    if handler then
      handler(args)
    else
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Uknown call '" .. method .. "' sent to hypervisor")
    end

    if args.copy then
      return copy(this)
    else
      return this
    end
  end

end

return M

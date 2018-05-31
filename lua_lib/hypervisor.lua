local D = require("lua_lib/util/dispatcher")
local T = require("lua_lib/util/type_assertion")

local M = {}

-- INSTRUCTIONS:
-- Use this as a template for new objects.
-- Replace "Hypervisor" with the name of your "class"

-- Generate a new state object for an `Hypervisor` instance.
local newHypervisorState = function()
  return {
    tick = coroutine.create(function()
      -- print("NOOP")
    end)
  }
end

function M.new()
  local state = newHypervisorState()
  local dispatch = D.create_dispatcher("Hypervisor", state)

  return function(cmd, args)
    T.is_string(cmd)
    T.maybe_table(args)

    return dispatch(cmd, args)
  end
end

return M

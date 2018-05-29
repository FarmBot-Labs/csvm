local D = require("lua_lib/util/dispatcher")
local T = require("lua_lib/util/type_assertion")

local M = {}

-- INSTRUCTIONS:
-- Use this as a template for new objects.
-- Replace "_____" with the name of your "class"

-- Generate a new state object for an `_____` instance.
local new_____State = function(anything_you_need_here)
  return {
    foo = function()
    end
  }
end

function M.new(anything_you_need_here)
  -- Just an example - Does not actually need to be a Function type.
  T.is_function(anything_you_need_here)

  local state = new_____State(input_queue, message_handler, hypervisor)
  local dispatch = D.create_dispatcher("_____", state)

  return function(cmd, args)
    T.is_string(cmd)
    T.maybe_table(args)

    return dispatch(cmd, args)
  end
end

return M

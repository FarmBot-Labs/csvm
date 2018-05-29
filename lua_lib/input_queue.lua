local D = require("lua_lib/util/dispatcher")
local T = require("lua_lib/util/type_assertion")

local M = {}

-- Generate a new state object for an `InputQueue` instance.
local newInputQueueState = function()
  return {
    get = function()
      error("NOT IMPLEMENTED")
    end
  }
end

function M.new()
  local state = newInputQueueState()
  local dispatch = D.create_dispatcher("InputQueue", state)

  return function(cmd, args)
    T.is_string(cmd)
    T.maybe_table(args)

    return dispatch(cmd, args)
  end
end

return M

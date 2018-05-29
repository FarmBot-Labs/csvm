local D = require("lua_lib/util/dispatcher")
local T = require("lua_lib/util/type_assertion")

local M = {}

-- Generate a new state object for an `App` instance.
local newAppState = function(anything_you_need_here)
  return {
    run = function()
      print("Starting run() loop...")
      while true do -- Change this to a tick()able coroutine.
        message = input_queue("get")
        if message then
          print("TODO: Use pl.pretty() here")
          -- TODO yield here.
          message_handler(message, hypervisor)
        else
          -- TODO yield here.
          hypervisor("tick")
        end
      end
    end
  }
end

function M.new(input_queue, message_handler, hypervisor)
  type_.is_function(input_queue)
  type_.is_function(message_handler)
  type_.is_function(hypervisor)

  local state = newAppState(input_queue, message_handler, hypervisor)
  local dispatch = D.create_dispatcher("App", state)

  return function(cmd, args)
    T.is_string(cmd)
    T.maybe_table(args)

    return dispatch(cmd, args)
  end
end

return M

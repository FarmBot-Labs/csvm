local D      = require("lua_lib/util/dispatcher")
local T      = require("lua_lib/util/type_assertion")
local M      = {}
local pretty = require "pl.pretty"

-- Generate a new state object for an `App` instance.
local newAppState = function(get_message, message_handler, hypervisor)
  -- The main run loop
  local run = function ()
    print("Starting run() loop...")
    while true do -- Change this to a tick()able coroutine.
      message = get_message()
      if message then
        local rpc_name = (message.namespace .. "." .. message.operation)
        print("Processing " .. rpc_name)
        message_handler(rpc_name, { payload    = message.payload,
                                    hypervisor = hypervisor })
      else
        hypervisor("tick")
      end
    end
  end

  return { run = run }
end

function M.new(get_message, message_handler, hypervisor)
  T.is_function(get_message)
  T.is_function(message_handler)
  T.is_function(hypervisor)

  local state = newAppState(get_message, message_handler, hypervisor)
  local dispatch = D.create_dispatcher("App", state)

  return function(cmd, args)
    T.is_string(cmd)
    T.maybe_table(args)

    return dispatch(cmd, args)
  end
end

return M

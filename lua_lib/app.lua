local D      = require("lua_lib/util/object")
local T      = require("lua_lib/util/type_assertion")
local M      = {}

-- Generate a new state object for an `App` instance.
local newAppMethodTable = function(get_message, message_handler)
  -- The main run loop
  local run = coroutine.create(function ()
    print("Starting run() loop...")
    while true do -- Change this to a tick()able coroutine.
      local message = get_message()
      if message then
        local rpc_name = (message.namespace .. "." .. message.operation)
        print("Processing " .. rpc_name)
        message_handler(rpc_name, { message = message })
      else
        message_handler("tick")
      end
      coroutine.yield()
    end
  end)

  return { run = run }
end

function M.new(get_message, message_handler)
  T.is_function(get_message)
  T.is_function(message_handler)

  local method_table = newAppMethodTable(get_message, message_handler)
  local state        = {}
  return D.create_object("App", method_table, state)
end

return M

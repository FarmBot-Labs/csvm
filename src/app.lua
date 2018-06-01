local D      = require("src/util/object")
local T      = require("src/util/type_assertion")
local M      = {}

-- Generate a new state object for an `App` instance.
local newAppMethodTable = function(get_message, vm)
  -- The main run loop
  return {
    ["run"] = coroutine.wrap(function (_, _)
      print("Starting run() loop...")
      while true do -- Change this to a tick()able coroutine.
        local message = get_message()
        if message then
          local rpc_name = (message.namespace .. "." .. message.operation)
          print("Processing " .. rpc_name)
          vm(rpc_name, { message = message })
        else
          vm("tick")
        end
        coroutine.yield()
      end
    end)
  }
end

function M.new(get_message, vm)
  T.is_function(get_message)
  T.is_function(vm)

  local method_table = newAppMethodTable(get_message, vm)
  local state        = {}
  return D.create_object("App", method_table, state)
end

return M

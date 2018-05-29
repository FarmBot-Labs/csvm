require("lua_lib/create_dispatcher")
require("lua_lib/type_assertion")

-- Generate a new state object for an `App` instance.
local newAppState = function (input_queue, message_handler, hypervisor)

  return {
    run = function ()
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

function App(input_queue, message_handler, hypervisor)
  is_function(input_queue)
  is_function(message_handler)
  is_function(hypervisor)

  local state    = newAppState(input_queue, message_handler, hypervisor)
  local dispatch = create_dispatcher("App", state)
  return function ( cmd, args )
    maybe_table(args)
    is_string(cmd)
    dispatch(cmd, args)
  end
end

local noop = function () end
local app = App(noop, noop, noop)

app("run")
app("Whoops")

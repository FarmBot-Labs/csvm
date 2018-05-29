require("lua_lib/create_dispatcher")

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

  local state    = newAppState(input_queue, message_handler, hypervisor)
  local dispatch = create_dispatcher("App", state)
  return function ( cmd, args )
    dispatch(cmd, args)
  end
end

local app = App()
app("run")
app("Whoops")

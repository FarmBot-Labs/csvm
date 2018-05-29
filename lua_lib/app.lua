local AppImplementation = function (input, message_handler, hypervisor)
  return {
    run = function ()
      print("Starting run() loop...")
      while true do -- Change this to a tick()able coroutine.
        message = input.get()
        if message then
          print("TODO: Use pl.pretty() here")
          message_handler(message, hypervisor)
          -- TODO yield here.
        else
          hypervisor.tick()
          -- TODO yield here.
        end
      end
    end
  }
end

function App(input, message_handler, hypervisor)

  local state = AppImplementation(input, message_handler, hypervisor)

  return function ( cmd, args )
    local fn = state[cmd]

    if fn then
      fn(args)
    else
      error("Unknown command " .. cmd)
    end
  end
end

local app = App()

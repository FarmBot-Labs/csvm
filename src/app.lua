local T  = require("src/util/type_assertion")
local IB = require("src/io/inbox")
local M  = {}

M.run = coroutine.wrap(function (get_message, vm)
  T.is_function(get_message)
  T.is_function(vm)
  print("Starting run() loop...")
  while true do
    local message = get_message()
    if message then
      print("X")
      vm({ message = message })
    else
      print("Y")
      vm({ message = IB.new_message(0, "SYS", "TICK") })
    end
    coroutine.yield()
  end
end)

return M

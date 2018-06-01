local T      = require("src/util/type_assertion")
local M      = {}

M.run = coroutine.wrap(function (get_message, vm)
  T.is_function(get_message)
  T.is_function(vm)
  print("Starting run() loop...")
  while true do
    local message = get_message()
    if message then
      local rpc_name = (message.namespace .. "." .. message.operation)
      vm(rpc_name, { message = message })
    else
      vm("SYS.TICK")
    end
    coroutine.yield()
  end
end)

return M

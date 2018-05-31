local pretty = require "pl.pretty"
local T      = require("lua_lib/util/type_assertion")
local M      = {}

function M.create_dispatcher(dispatcher_name, lookup_table)
  return function(message_name, args)
    local handler = lookup_table["" .. message_name]
    if (handler) then
      T.is_thread(handler)
      return coroutine.resume(handler, args)
    else
      pretty.dump(lookup_table)
      error("Unnown action '" .. message_name .. "' sent to '" .. dispatcher_name .. "'")
    end
  end
end

return M

local pretty = require "pl.pretty"
local T      = require("lua_lib/util/type_assertion")
local M      = {}

function M.create_object(class_name, lookup_table, initial_state)
  T.is_string(class_name)
  T.is_table(lookup_table)
  T.is_table(initial_state)
  local state = initial_state
  return function(method, args)
    local handler = lookup_table["" .. method]
    if (handler) then
      T.is_thread(handler)
      T.is_string(method)
      T.maybe_table(args)
      state = coroutine.resume(handler, state, args) or state
    else
      pretty.dump(lookup_table)
      local err = "Unnown method '" ..
                  method ..
                  "' sent to '" ..
                  class_name ..
                  "'"
      error(err)
    end
  end
end

return M

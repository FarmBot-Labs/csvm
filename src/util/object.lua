local pretty = require "pl.pretty"
local T      = require("src/util/type_assertion")
local M      = {}

function M.create_object(class_name, lookup_table, initial_state)
  T.is_string(class_name)
  T.is_table(lookup_table)
  T.is_table(initial_state)
  local state = initial_state
  return function(method, args)
    T.is_string(method)
    local handler = lookup_table[method]
    if (handler) then
      T.is_thread(handler)
      T.maybe_table(args)
      coroutine.resume(handler, state, args)
    else
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Unnown method '" ..
            method ..
            "' sent to '" ..
            class_name ..
            "'")
    end
  end
end

return M

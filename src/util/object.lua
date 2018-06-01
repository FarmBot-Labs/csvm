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
    T.maybe_table(args)
    local handler = lookup_table[method]
    local t = type(handler)

    if (t == "thread") then
      -- local ok =
       coroutine.resume(handler, state, args)
      -- if ok then
      --   print("OK")
        return
      -- else
      --   error("coroutine failure: " .. method)
      -- end
    end

    if (t == "function") then
      handler(state, args)
      return
    end

    if(t == "nil") then
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Uknown method '" .. method .. "' sent to '" .. class_name .. "'")
    end

    error("Expected method handler to be function or coroutine. Got: " .. t)
  end
end

return M

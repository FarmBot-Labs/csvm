local D = require("src/util/object")
local T = require("src/util/type_assertion")

local M = {}

-- INSTRUCTIONS:
-- Use this as a template for new objects.
-- Replace "_____" with the name of your "class"

-- Generate a new state object for an `_____` instance.
local new_____MethodTable = function()
  return {
    foo = coroutine.create(function()
    end)
  }
end

function M.new()
  -- Just an example - Does not actually need to be a Function type.
  T.is_function(function()end)

  local methods = new_____MethodTable()
  return D.create_object("_____", methods)
end

return M

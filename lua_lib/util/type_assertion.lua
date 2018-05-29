-- Setting `maybe` to true allows `nil` values.
local is_a = function(kind, maybe)
  return function(value)
    local t = type(value)
    local expectation = (t == kind)

    if maybe and (t == "nil") then
      return
    else
      assert(expectation, "Expected " .. kind .. " variable. See trace.")
    end
  end
end

local M = {}

M.is_function = is_a("function")
M.is_string = is_a("string")
M.is_table = is_a("table")
M.is_number = is_a("number")

M.maybe_table = is_a("table", true)

return M

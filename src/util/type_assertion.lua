local M = {}

-- Setting `maybe` to true allows `nil` values.
local is_a = function(kind, maybe)
  return function(value)
    local t = type(value)
    local expectation = (t == kind)

    if maybe and (t == "nil") then
      return
    else
      local err =
        "Expected " .. kind .. " type. Got: " .. t .. ". See trace for details."
      assert(expectation, err)
    end
  end
end

function M.is_function (fn, maybe)

  local t = type(fn)
  if maybe and (t == "nil") then
    return
  end

  if type(fn) == "function" then
    return
  end

  local mt = getmetatable(fn)

  if mt and mt.__call then
    return
  end

  assert(false,
    "Expected function type. Got: " .. t .. ". See trace for details.")
end

M.is_string = is_a("string")
M.is_thread = is_a("thread")
M.is_table  = is_a("table")
M.is_number = is_a("number")

M.maybe_number   = is_a("number", true)
M.maybe_table    = is_a("table",  true)
M.maybe_string   = is_a("string", true)
M.maybe_function = function(fn) M.is_function(fn, true) end

return M

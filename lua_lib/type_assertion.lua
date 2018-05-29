-- Setting `maybe` to true allows `nil` values.
function is_a(kind, maybe)
  return function (value)
    local t = type(value)
    local expectation = (t == kind)
    if maybe and (t == "nil") then
      return
    else
      assert(expectation, "Expected "  .. kind .. " variable. See trace.")
    end
  end
end

is_function = is_a("function")
is_table    = is_a("table")
maybe_table = is_a("table", true)
is_string   = is_a("string")

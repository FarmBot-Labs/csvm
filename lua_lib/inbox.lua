local T = require("lua_lib/util/type_assertion")
local M = {}

function M.fetch()
  local i = _G.inbox
  T.is_table(i)
  T.is_number(i.index)
  local last = i[i.index]
  T.maybe_table(last)
  if last then
    T.is_number(last.channel)
    T.is_string(last.namespace)
    T.is_string(last.operation)
    T.maybe_string(last.payload)
  end
  i[i.index] = nil
  i.index = (i.index + 1)
  return last
end

return M

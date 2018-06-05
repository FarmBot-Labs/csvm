local T    = require("src/util/type_assertion")
local M    = {}
local CLRF = "\r\n"

-- Swap this out in the test suite as needed - RC
M.raw_write = io.write

function M.reply(channel, status, value)
  T.is_number(channel)
  T.is_number(status)
  T.maybe_number(value)

  M.raw_write("" .. channel .. status .. (value or "") .. CLRF)
end

return M

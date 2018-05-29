local type_ = require("lua_lib/util/type_assertion")

local M = {}

local inputQueueState = function ()
  return {
    get = function ()
    end
  }
end

function M.InputQueue ()

  return function (cmd, args)
    type_.is_string(cmd)
    type_.maybe_table(args)
  end
end

return M

local List = require("pl.List")
local M = {}

M.BAD_ADDR = "Bad node address: "
M.LINK     = "__"
M.NULL     = 1
M.PARENT   = M.LINK .. "parent"
M.BODY     = M.LINK .. "body"
M.NEXT     = M.LINK .. "next"
M.KIND     = M.LINK .. "KIND"
M.COMMENT  = M.LINK .. "COMMENT"
M.NOTHING  = { [M.KIND  ] = "nothing",
               [M.PARENT] = M.NULL,
               [M.BODY  ] = M.NULL,
               [M.NEXT  ] = M.NULL }
M.PRIMARY_FIELDS = { M.PARENT, M.BODY, M.KIND, M.NEXT, M.COMMENT }

function M.new ()
  local this   = {}
  this.here    = M.NULL
  this.entries = List.new{ M.NOTHING }

  this.allot   = function(kind)
    this.here = this.here + 1
    this.entries:append({ [M.KIND] = kind })
    return this.here
  end

  this.get = function(address)
    local cell = this.entries[address]
    if cell then return cell else error(M.BAD_ADDR .. address) end
  end

  this.put = function (address, key, value)
    this.get(address)[key] = value
  end

  return this
end

return M

local List = require("pl.List")
local M = {}

M.BAD_ADDR       = "Bad node address: "
M.LINK           = "__"
M.PARENT         = (M.LINK .. "parent")
M.BODY           = (M.LINK .. "body")
M.NEXT           = (M.LINK .. "next")
M.KIND           = "__KIND__"
M.COMMENT        = "__COMMENT__"
M.NULL           = 1
M.NOTHING        = { [M.KIND  ] = "nothing",
                     [M.PARENT] = M.NULL,
                     [M.BODY  ] = M.NULL,
                     [M.NEXT  ] = M.NULL }
M.PRIMARY_FIELDS = { M.PARENT, M.BODY, M.KIND, M.NEXT, M.COMMENT }

function M.BadAddress(val)
    error(M.BAD_ADDR .. val)
end

function M.new ()
  local this   = {}
  this.here    = M.NULL
  this.entries = List.new{ M.NOTHING }

  this.allot   = function(kind)
    this.here = this.here + 1
    this.entries:append({ KIND = kind })
    return this.here
  end

  this.put = function (address, key, value)
    --   M.is_address(address)
      local block = this.entries:index(address)
      if block then
        block[key] = value
        return
      else
        M.BadAddress(address.inspect)
      end
    end

  return this
end

return M

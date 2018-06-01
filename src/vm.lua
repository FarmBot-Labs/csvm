local D = require("src/util/object")
local M = {}
local json = require("lib/json")

local wip = coroutine.create(function () error("Work in progress") end)

-- Generate a new method_table object for a `VM` instance.
local newVMMethodTable = function()
  local code_counter = 0
  return {
    ["tick"]                             = wip,
    ["CODE.WRITE"]                       = coroutine.create(function(s, a)
      code_counter         = code_counter + 1
      s.code[code_counter] = json.decode(a.payload)
      print("Hooray! " .. a.payload)
    end),
    ["CODE.RM"]                          = wip,
    ["PROC.KILL"]                        = wip,
    ["PROC.PAUSE"]                       = wip,
    ["PROC.RUN"]                         = wip,
    ["PROC.START"]                       = wip,
    ["REGISTER.NEW"]                     = wip,
    ["SLICE.NEW"]                        = wip,
    ["SYS.CALIBRATE"]                    = wip,
    ["SYS.CHECK_UPDATES"]                = wip,
    ["SYS.CONFIG_UPDATE"]                = wip,
    ["SYS.EXECUTE_SCRIPT"]               = wip,
    ["SYS.EXIT"]                         = wip,
    ["SYS.FACTORY_RESET"]                = wip,
    ["SYS.FIND_HOME"]                    = wip,
    ["SYS.HOME"]                         = wip,
    ["SYS.INSTALL_FARMWARE"]             = wip,
    ["SYS.INSTALL_FIRST_PARTY_FARMWARE"] = wip,
    ["SYS.MOVE_ABSOLUTE"]                = wip,
    ["SYS.MOVE_RELATIVE"]                = wip,
    ["SYS.POWER_OFF"]                    = wip,
    ["SYS.REBOOT"]                       = wip,
    ["SYS.REGISTER_GPIO"]                = wip,
    ["SYS.REMOVE_FARMWARE"]              = wip,
    ["SYS.SEND_MESSAGE"]                 = wip,
    ["SYS.SET_SERVO_ANGLE"]              = wip,
    ["SYS.SET_USER_ENV"]                 = wip,
    ["SYS.SLEEP"]                        = wip,
    ["SYS.TAKE_PHOTO"]                   = wip,
    ["SYS.TOGGLE_PIN"]                   = wip,
    ["SYS.UNREGISTER_GPIO"]              = wip,
    ["SYS.UPDATE_FARMWARE"]              = wip,
    ["SYS.WAIT"]                         = wip,
    ["SYS.WRITE_PIN"]                    = wip,
    ["SYS.ZERO"]                         = wip,
  }
end

function M.new()
  return D.create_object("VM", newVMMethodTable(), { code = {} })
end

return M

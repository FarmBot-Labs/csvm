local M      = {}
local json   = require("lib/json")
local pretty = require("pl.pretty")
local wip    = function () error("Work in progress") end
local T      = require("src/util/type_assertion")

function M.new()
  local this = {
    code_counter = 0,
    code = {}
  }

  local lookup_table = {
    ["SYS.TICK"]                         = function(_)
      -- TODO: Tick the VM in a round robin.
    end,
    ["CODE.WRITE"]                       = function(a)
      this.code_counter = this.code_counter + 1
      this.code[this.code_counter] = json.decode(a.message.payload)
      print("Registered code under ID " .. this.code_counter .. ":")
      pretty.dump(this.code[this.code_counter])
    end,
    ["PROC.START"]                       = wip,
    ["PROC.KILL"]                        = wip,
    ["PROC.PAUSE"]                       = wip,
    ["PROC.RUN"]                         = wip,
    ["CODE.RM"]                          = wip,
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

  return function(method, args)
    T.maybe_table(args)
    local handler = lookup_table[method]
    if handler then
      handler(args)
      return
    else
      print("BAD METHOD NAME! Pick one of these:")
      pretty.dump(lookup_table)
      error("Uknown call '" .. method .. "' sent to hypervisor")
    end
  end

end

return M

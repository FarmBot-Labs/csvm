local I   = require("src/interpreter/instructions")
local M   = {}
local Ops = require("src/interpreter/ops")
local T   = require("src/util/type_assertion")

M.instructions = {
  ["sequence"]       = I.sequnece,
  ["move_absolute"]  = I.move_absolute,
  ["move_relative"]  = I.move_relative,
  ["write_pin"]      = I.write_pin,
  ["read_pin"]       = I.read_pin,
  ["wait"]           = I.wait,
  ["send_message"]   = I.send_message,
  ["find_home"]      = I.find_home,
  ["_if"]            = I._if,
  ["execute"]        = I.execute,
  ["execute_script"] = I.execute_script,
  ["take_photo"]     = I.take_photo,
  ["nothing"]        = I.nothing,
}

M.fetch = function(proc)
  return Ops.get_kind(Ops.get_pc_cell(proc))
end

M.decode = function(kind)
  local exec = M.instructions[kind]
  if type(exec) == "function" then
    return exec
  else
    error("Cant decode CS node '" .. kind .. "'")
  end
  return exec
end

M.tick = function(proc)
  T.is_table(proc)
  T.is_table(proc.CODE)
  T.is_number(proc.PC)
  -- TODO: Maybe add pause / resume in here.
  local next_instruction = M.fetch(proc)
  local executor         = M.decode(next_instruction)
  executor(proc)
end

return M

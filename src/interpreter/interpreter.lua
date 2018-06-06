local T   = require("src/util/type_assertion")
local Ops = require("src/interpreter/ops")
local M   = {}

local handle_sequnece = function(proc)
  local cell      = Ops.get_pc_cell(proc)
  local body_addr = Ops.maybe_get_body_address(cell)
  if body_addr then
    print("This sequence has a body. Entering.")
    Ops.enter(proc, body_addr)
  else
    print("This sequence has no body. Exiting.")
    Ops.exit(proc)
  end
end

local handle_move_absolute = function(proc)
  local cell     = Ops.get_pc_cell(proc)
  local offset   = Ops.get_param(proc, "offset")
  local location = Ops.get_param(proc, "location")
  local go_to  = { x = 0, y = 0, z = 0 }
  Ops.pretend("Move abs.")
  M.next_or_exit(proc)
end

-- ENTER
-- NEXT
-- EXIT
-- NEXT_OR_EXIT ( __next == NULL ? EXIT : NEXT )

M.instructions = {
  ["sequence"]      = handle_sequnece,
  ["move_absolute"] = handle_move_absolute
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
  local next_instruction = M.fetch(proc)
  local executor         = M.decode(next_instruction)
  executor(proc)
end

return M

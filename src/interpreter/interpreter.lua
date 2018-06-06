local T = require("src/util/type_assertion")
local H = require("src/interpreter/helpers")
local M = {}


-- ENTER
-- NEXT
-- EXIT
-- NEXT_OR_EXIT ( __next == NULL ? EXIT : NEXT )

M.instructions = {
  ["sequence"] = function(proc)
    local cell      = H.get_cell(proc)
    local body_addr = H.maybe_get_body_address(cell)
    if body_addr then
      print("This sequence has a body. Entering.")
      H.enter(proc, body_addr)
    else
      print("This sequence has no body. Exiting.")
      H.exit(proc)
    end
  end
}

M.fetch = function(proc)
  return H.get_kind(H.get_cell(proc))
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

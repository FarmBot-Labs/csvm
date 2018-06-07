local H   = require("src/interpreter/helpers")
local M   = {}
local Ops = require("src/interpreter/ops")
local T   = require("src/util/type_assertion")
local P   = require("src/process/process")

M.sequnece = function(proc)
  local cell      = Ops.get_pc_cell(proc)
  local body_addr = Ops.maybe_get_body_address(cell)
  if body_addr then
    print("This sequence has a body. Entering.")
    Ops.call(proc, body_addr)
  else
    print("This sequence has no body. Exiting.")
    Ops.return_(proc)
  end
end

M.move_absolute = function(proc)
  local cell     = Ops.get_pc_cell(proc)
  local off_cell = Ops.get_param_cell(proc, cell, "offset")
  local loc_cell = Ops.get_param_cell(proc, cell, "location")
  local offset   = H.extract_vector_from_cell(proc, off_cell)
  local location = H.extract_vector_from_cell(proc, loc_cell)
  local go_to    = { x = (location.x + offset.x),
                     y = (location.y + offset.y),
                     z = (location.z + offset.z) }
  Ops.pretend("Move abs", go_to)
  Ops.step_or_return(proc, cell)
end

M.move_relative = function(proc)
  local cell     = Ops.get_pc_cell(proc)
  local x = cell["x"]; T.is_number(x)
  local y = cell["y"]; T.is_number(y)
  local z = cell["z"]; T.is_number(z)
  local go_to    = { x = x , y = y , z = z }
  Ops.pretend("Move relative", go_to)
  Ops.step_or_return(proc, cell)
end

M.write_pin = function(proc)
  local cell     = Ops.get_pc_cell(proc)

  local pin_value  = cell["pin_value"];  T.is_number(pin_value)
  local pin_mode   = cell["pin_mode"];   T.is_number(pin_mode)
  local pin_number = cell["pin_number"]; T.is_number(pin_number)

  Ops.pretend("write pin")

  Ops.step_or_return(proc, cell)
end

M.read_pin = function(proc)
  local cell     = Ops.get_pc_cell(proc)

  local label      = cell["label"];      T.is_string(label)
  local pin_mode   = cell["pin_mode"];   T.is_number(pin_mode)
  local pin_number = cell["pin_number"]; T.is_number(pin_number)

  Ops.pretend("Read a pin")

  Ops.step_or_return(proc, cell)
end

M.wait = function(proc)
  local cell     = Ops.get_pc_cell(proc)

  local milliseconds = cell["milliseconds"]; T.is_number(milliseconds)

  Ops.pretend("wait (in ms) ")

  Ops.step_or_return(proc, cell)

end

M.send_message = function(proc)
  local cell     = Ops.get_pc_cell(proc)
  local message      = cell["message"];      T.is_string(message)
  local message_type = cell["message_type"]; T.is_string(message_type)
  print("TODO: Collect channels")
  Ops.pretend("send message")

  Ops.step_or_return(proc, cell)
end

M.find_home = function(proc)
  local cell     = Ops.get_pc_cell(proc)
  local axis = cell["axis"]; T.is_string(axis)
  Ops.pretend("find home")

  Ops.step_or_return(proc, cell)
end

M._if = function(proc)
  local cell      = Ops.get_pc_cell(proc)
  local op        = cell["op"];  T.is_string(op)
  local lhs       = cell["lhs"]; T.is_string(lhs)
  local rhs       = cell["rhs"]; T.is_number(rhs)
  local then_cell = Ops.get_param_cell(proc, cell, "_then")
  local else_cell = Ops.get_param_cell(proc, cell, "_else")
  T.is_table(then_cell) -- Remove after implementing real I/O
  T.is_table(else_cell) -- Remove after implementing real I/O

  Ops.pretend("do an _if")
  Ops.step_or_return(proc, cell)
end


M._if = function(proc)
  local cell = Ops.get_pc_cell(proc)
  local op   = cell["op"];  T.is_string(op)
  local rhs  = cell["rhs"]; T.is_number(rhs)

  Ops.pretend("do an _if")
  Ops.step_or_return(proc, cell)
end

M.execute = function(proc)
  local cell        = Ops.get_pc_cell(proc)
  local sequence_id = cell["sequence_id"]; T.is_number(sequence_id)

  Ops.pretend("execute another sequence")
  Ops.step_or_return(proc, cell)
end

M.execute_script = function(proc)
  local cell  = Ops.get_pc_cell(proc)
  local label = cell["label"]; T.is_string(label)
  print("TODO: Collect pairs")
  Ops.pretend("execute a farmware")
  Ops.step_or_return(proc, cell)
end

M.take_photo = function(proc)
  local cell  = Ops.get_pc_cell(proc)
  Ops.pretend("take a photo")
  Ops.step_or_return(proc, cell)
end

M.nothing = function(proc)
  proc.STAT = P.status.DONE
end

return M

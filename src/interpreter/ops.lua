local Heap = require("src/slicer/heap")
local T    = require("src/util/type_assertion")
local M    = {}
M.enter = function(proc, addr)
  local pc = M.get_pc_addr(proc)
  M.push_rs(proc, pc)
  M.set_pc(proc, addr)
end

M.exit = function(proc)
  error("WIP")
end

M.next = function(proc)
  error("WIP")
end

M.next_or_exit = function(proc)
  local addr = M.maybe_get_next_address(proc)
  if addr then
    M.next(proc)
  else
    M.exit(proc)
  end
end

M.is_addr = function(proc, addr)
  T.is_number(addr)
  T.is_table(proc.CODE[addr])
end

M.set_pc = function(proc, addr)
  proc.PC = addr
  return proc
end

M.get_kind = function(cell)
  local kind = cell[Heap.KIND]
  T.is_string(kind)
  return kind
end

M.maybe_get_body_address = function(cell)
  local addr = cell[Heap.BODY]
  if addr and addr ~= Heap.NULL then
    return addr
  end
end

M.maybe_get_next_address = function(cell)
  local addr = cell[Heap.NEXT]
  if addr and addr ~= Heap.NULL then
    return addr
  end
end

M.get_pc_cell = function(proc)
  local pc_addr = M.get_pc_addr(proc)
  local tbl = proc.CODE[pc_addr]
  T.is_table(tbl)
  return tbl
end

M.push_rs = function(proc, addr)
  M.is_addr(proc, addr)
  proc.RS:push{ address = 1, sequence = -1 }
end

M.get_pc_addr = function(proc)
  local pc = proc.PC
  M.is_addr(proc, pc)
  return pc
end

M.get_param_cell = function(proc, cell, name)
  T.is_table(cell)
  T.is_string(name)
  local param_addr = cell[Heap.LINK .. name]
  M.is_addr(proc, param_addr)

  if param_addr then
    local cell = proc.CODE[param_addr]
    T.is_table(cell)
    return cell
  else
    error("BAD PARAM: " .. name)
  end
end

M.pretend = function(label)
  print("Pretending to perfom " .. label)
end
return M

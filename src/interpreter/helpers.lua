local Heap = require("src/slicer/heap")
local T    = require("src/util/type_assertion")
local M    = {}

M.enter = function(proc, addr)
  local pc = M.get_pc(proc)
  M.push_rs(proc, pc)
  M.set_pc(proc, addr)
  error("WIP")
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

M.set_pc = function(proc, addr)
  T.is_number(addr)
  T.is_table(proc.CODE[addr])
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

M.get_cell = function(proc)
  local tbl = proc.CODE[proc.PC]
  T.is_table(tbl)
  return tbl
end

M.push_rs = function(proc, pc)
  error("WIP")
end

M.get_pc = function(proc)
  local pc = proc.PC
  T.is_number(pc)
  return pc
end

return M

local Heap = require("src/slicer/heap")
local T    = require("src/util/type_assertion")
local M    = {}

M.call = function(proc, addr)
  local pc_addr = M.get_pc_addr(proc)
  M.push_rs(proc, pc_addr)
  M.set_pc(proc, addr)
end

M.step = function(proc)
  local this_cell = M.get_pc_cell(proc)
  local next_addr = this_cell[Heap.NEXT]
  M.set_pc(proc, next_addr)
end

M.return_ = function(proc)
  local caller_addr = M.pop_rs(proc)
  M.set_pc(proc, caller_addr) -- Go back to caller
  M.step(proc)                -- Step to next node
end

M.step_or_return = function(proc, cell)
  local addr = M.maybe_get_next_address(cell)
  if addr then
    M.step(proc)
  else
    M.return_(proc)
  end
end

M.is_addr = function(proc, addr)
  T.is_table(proc)
  T.is_number(addr)
  T.is_table(proc.CODE[addr])
end

M.set_pc = function(proc, addr)
  M.is_addr(proc, addr)
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
  T.is_table(cell)
  local addr = cell.__next
  T.maybe_number(addr)
  local null = (addr == Heap.NULL)
  if (not null) and addr then return addr end
end

M.get_pc_cell = function(proc)
  local pc_addr = M.get_pc_addr(proc)
  local tbl = proc.CODE[pc_addr]
  T.is_table(tbl)
  return tbl
end

M.push_rs = function(proc, addr)
  M.is_addr(proc, addr)
  proc.RS:push{ address = addr, sequence = -1 }
end

M.pop_rs = function(proc)
  local stack_frame = proc.RS:pop()
  T.is_table(stack_frame)
  local return_address = stack_frame.address
  print("return_address is " .. return_address)
  M.is_addr(proc, return_address)
  return return_address
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

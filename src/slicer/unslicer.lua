local Heap    = require("src/slicer/heap")
local List    = require("pl.List")
local M       = {}

local handlers = {
  [Heap.BODY]    = function(heap, _, output, value)
    if (heap[value][Heap.KIND] == "nothing") then return nil end
    output.body     = List.new()
    local next_addr = value
    local n         = heap[next_addr]
    local count     = 0
    while n and (n[Heap.KIND] ~= "nothing") do
      count = count + 1
      if (count > 1000) then error("Runaway loop") end
      local item = M.unslice(heap, next_addr)
      output.body.push(item)
      next_addr = item[Heap.NEXT]
      n         = heap[next_addr]
    end
  end,
  [Heap.KIND]    = function(_, _, output, value)
    output.kind = value
  end,
  [Heap.PARENT]  = function() end,
  [Heap.NEXT]    = function() end,
  [Heap.COMMENT] = function() end,
  [Heap.NOTHING] = function() end,
}

local default_handler = function(heap, _, output, value, key)
  output.args[key:gsub("__", "")] = M.unslice(heap, value)
end

M.unslice = function (heap, address)
  local output = { args = {} }
  local here   = heap[address]

  for k, value in pairs(here) do
    if (k:sub(1, 2) == "__") then
      local handler = (handlers[k] or default_handler)
      handler(heap, address, output, value, k)
    else
      output.args[k] = value
    end
  end
  return output
end

return M

local Heap    = require("src/slicer/heap")
-- local inspect = require("pl.pretty")
local List    = require("pl.List")
local M       = {}

-- local handlers = {
--   [M.PARENT]  = function() end,
--   [M.BODY]    = function() end,
--   [M.NEXT]    = function() end,
--   [M.KIND]    = function() end,
--   [M.COMMENT] = function() end,
--   [M.NOTHING] = function() end,
-- }

-- local default_handler = function()
-- end

M.unslice = function (heap, address)
  local output = { args = {} }
  local here   = heap[address]

  for k, value in pairs(here) do
    if (k:sub(1, 2) == "__") then
      print("KEY: " .. k .. " VALUE: " .. value)
      if k == Heap.KIND then
        output.kind = value
      end

      if k == Heap.BODY then
        output.body      = List.new()
        local next_addr  = here[Heap.BODY]
        local n          = heap[next_addr]
        local count      = 0
        while n and (n[Heap.KIND] ~= "nothing") do
          count = count + 1
          if (count > 1000) then error("Runaway loop") end
          local item = M.unslice(heap, next_addr)
          output.body.push(item)
          next_addr = item[Heap.NEXT]
          n         = heap[next_addr]
        end
      end
    else
      output.args[k] = value
    end
  end
  return output
end

return M

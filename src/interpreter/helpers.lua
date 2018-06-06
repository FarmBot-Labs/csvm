local M    = {}
local T    = require("src/util/type_assertion")
local Heap = require("src/slicer/heap")
local Ops = require("src/interpreter/ops")

M.extract_vector_from_cell = function (_, cell)
  local kind = cell[Heap.KIND]

  if kind == "nothing" then return { x = 0, y = 0, z = 0 } end

  if kind == "coordinate" then
    local x = cell.x
    T.is_number(x)

    local y = cell.y
    T.is_number(y)

    local z = cell.z
    T.is_number(z)

    return { x = x, y = y, z = z }
  end

  if kind == "point" then
    Ops.pretend("x/y/z resolve on point. For now, Stub with 1.2.3")
    return { x = 1, y = 2, z = 3 }
  end

  if kind == "identifier" then
    error("Identifier yet impl.")
  end

  if kind == "tool" then
    error("Tool yet impl.")
  end
  error("Dont know how to create vector from " .. kind .. " yet.")
end

return M

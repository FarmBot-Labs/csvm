local M    = {}
local T    = require("src/util/type_assertion")
local Heap = require("src/slicer/heap")

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
    error("Not yet impl.")
  end

  if kind == "identifier" then
    error("Not yet impl.")
  end

  if kind == "tool" then
    error("Not yet impl.")
  end
  error("Dont know how to create vector from " .. kind .. " yet.")
end

return M

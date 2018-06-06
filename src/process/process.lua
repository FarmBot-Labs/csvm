local S = require("src/slicer/slicer")
local M = {}

M.new = function (celery_script)
  return { PC = 1, CODE = S.new().run(celery_script) }
end

return M

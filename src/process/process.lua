local S    = require("src/slicer/slicer")
local M    = {}
local T    = require("src/util/type_assertion")
local List = require("pl.List")

M.status = {
  OK    = "OK",
  PAUSE = "PAUSE",
  DONE  = "DONE"
}

M.new = function (celery_script)
  T.is_table(celery_script)

  return {
    STAT = M.status.OK,
    RS = List.new({ address = 1, sequence = celery_script.id }),
    PC = 2,
    CODE = S.new().run(celery_script)
  }
end

return M

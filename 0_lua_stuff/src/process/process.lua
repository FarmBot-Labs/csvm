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
    -- The status of the process
    STAT = M.status.OK,
    -- Return stack
    RS   = List.new({ address = 1, sequence = celery_script.id }),
    -- Program Counter (next instruction to execute)
    PC   = 2,
    -- Program Memory
    CODE = S.new().run(celery_script)
  }
end

return M

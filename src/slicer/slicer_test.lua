local S      = require("src/slicer/slicer")
local F      = require("src/slicer/fixtures")
local decode = require("lib/json").decode
local dump   = require("pl.pretty").dump

describe("slicer", function()
  it("slices", function ()
    local seq    = decode(F.example1)
    local s      = S.new()
    local result = s.run(seq)
    dump(result)
  end)
end)

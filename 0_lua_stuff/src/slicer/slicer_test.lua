local S      = require("src/slicer/slicer")
local F      = require("src/slicer/fixtures")
local H      = require("src/slicer/heap")
local json   = require("lib/json")

describe("slicer", function()
  -- This is here mostly for syntax checking.
  -- Visually inspect heap output using `dot_generator.rb`.
  it("slices", function ()
    local seq  = json.decode(F.example1)
    local s    = S.new()
    local heap = s.run(seq)

    assert.are.same(heap[1][H.KIND],   "nothing")
    assert.are.same(heap[2][H.KIND],   "sequence")
    assert.are.same(heap[2][H.PARENT], 1)
    assert.are.same(heap[2][H.BODY],   3)
    assert.are.same(heap[2][H.NEXT],   1)
  end)
end)

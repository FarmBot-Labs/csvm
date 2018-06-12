local U = require("src/slicer/unslicer")
local F = require("src/slicer/fixtures")

describe("unslicer", function()
  it("unslices move_abs", function ()
    local results = U.unslice(F.sliced_example1, 3)

    assert.are.same(type(results),      "table")
    assert.are.same(results.kind,       "move_absolute")
    assert.are.same(results.body,       nil)
    assert.are.same(results.args.speed, 100)

    assert.are.same(type(results.args),          "table")
    assert.are.same(type(results.args.offset),   "table")
    assert.are.same(type(results.args.location), "table")

    assert.are.same(results.args.offset.kind,   "coordinate")
    assert.are.same(results.args.offset.args.x, 0)
    assert.are.same(results.args.offset.args.y, 0)
    assert.are.same(results.args.offset.args.z, 0)

    assert.are.same(results.args.location.kind,              "point")
    assert.are.same(results.args.location.args.pointer_id,   20246)
    assert.are.same(results.args.location.args.pointer_type, "Plant")
  end)

  -- it("unslices move_relative", function ()
  --   local results = U.unslice(F.sliced_example1, 6)
  --   assert.are.same(type(results),      "table")
  --   assert.are.same(results.kind,       "move_relative")
  --   assert.are.same(type(results.args), "table")
  --   assert.are.same(results.args.speed, 100)
  --   assert.are.same(results.args.x,     0)
  --   assert.are.same(results.args.y,     0)
  --   assert.are.same(results.args.z,     0)
  -- end)

  -- it("Unslices things that have `body` attrs")
end)

local U = require("src/slicer/unslicer")
local F = require("src/slicer/fixtures")

-- { -- Index 3
--   "kind": "move_absolute",
--   "args": {
--       "speed": 100,
--       "offset": {
--           "kind": "coordinate",
--           "args": {
--               "z": 0,
--               "y": 0,
--               "x": 0
--           }
--       },
--       "location": {
--           "kind": "point",
--           "args": {
--               "pointer_id": 20246,
--               "pointer_type": "Plant"
--           }
--       }
--   }
-- }
describe("unslicer", function()
  it("unslices move_abs", function ()
    local results = U.unslice(F.sliced_example1, 3)
    assert.are.same(type(results),               "table")
    assert.are.same(results.kind,                "move_absolute")
    assert.are.same(results.args.speed,          100)
    assert.are.same(results.args.x,              0)
    assert.are.same(results.args.y,              0)
    assert.are.same(results.args.z,              0)
    assert.are.same(type(results.args),          "table")
    assert.are.same(type(results.args.offest),   "table")
    assert.are.same(type(results.args.location), "table")
  end)

  it("unslices move_relative", function ()
    local results = U.unslice(F.sliced_example1, 6)
    assert.are.same(type(results),      "table")
    assert.are.same(results.kind,       "move_relative")
    assert.are.same(type(results.args), "table")
    assert.are.same(results.args.speed, 100)
    assert.are.same(results.args.x,     0)
    assert.are.same(results.args.y,     0)
    assert.are.same(results.args.z,     0)
  end)

  it("Unslices things that have `body` attrs")
end)

local S      = require("src/slicer/slicer")
local F      = require("src/slicer/fixtures")
local json   = require("lib/json")

describe("slicer", function()
  it("slices", function ()
    -- "move_absolute"
    -- "move_relative"
    -- "write_pin"
    -- "read_pin"
    -- "wait"
    -- "send_message"
    -- "find_home"
    -- "_if"
    -- "execute"
    -- "execute_script"
    -- "take_photo"

    local seq    = json.decode(F.example1)
    local s      = S.new()
    local result = s.run(seq)
    print(json.encode(result))
  end)
end)

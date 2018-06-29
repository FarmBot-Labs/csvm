-- Test harness for integration tests.
local F        = require("src/slicer/fixtures")
local Proc     = require("src/process/process")
local json     = require("lib/json")
local sequence = F.example1
local I        = require("src/interpreter/interpreter")
local proc     = Proc.new(json.decode(sequence))
local OK       = Proc.status.OK

print("START")
local count = 0

while (proc.STAT == OK) do
  count = count + 1
  print("Tick #" .. count .. ". Status: " .. proc.STAT)
  I.tick(proc)
end

print("END")

-- Test harness for integration tests.
local F        = require("src/slicer/fixtures")
local Proc     = require("src/process/process")
local sequence = F.example1
local I        = require("src/interpreter/interpreter")
local proc     = Proc.new(sequence)

print("START")
local OK = Proc.status.OK

while (proc.stat == OK) do
  I.tick(proc)
end

print("END")

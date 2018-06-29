defmodule Csvm.InstructionSetTest do
  use ExUnit.Case
  alias Csvm.{AST, FarmProc}
  alias AST.Slicer

  @fixture AST.decode(%{
    kind: :_if,
    args: %{ lhs: :x, op: "is", rhs: 10,
             _then: %{ kind: :nothing, args: %{} },
             _else: %{ kind: :nothing, args: %{} } }
  })

  test "Slices a realistic sequence" do
    fun       = fn (_) -> {:error, "whatever"} end
    heap      = Slicer.run(@fixture)
    farm_proc = FarmProc.new(fun, 1, heap)
    crashed   = FarmProc.step(farm_proc)
    assert FarmProc.get_status(crashed) == :crashed
    assert FarmProc.get_crash_reason(crashed) == "whatever"
  end
end

defmodule Csvm.ResolverTest do
  use ExUnit.Case, async: true
  alias Csvm.{ Resolver, AST, FarmProc }
  import Csvm.Utils

  def fetch_fixture(fname) do
    File.read!(fname)
      |> Jason.decode!()
      |> AST.decode()
      |> AST.Slicer.run()
  end

  test "variable resolution" do
    fun        = fn _ -> {:error, "whatever"} end
    inner_json = fetch_fixture("fixture/inner_sequence.json")
    outer_json = fetch_fixture("fixture/outer_sequence.json")
    farm_proc0 = FarmProc.new(fun, addr(0), outer_json)
    farm_proc1 = Enum.reduce(0..3, farm_proc0, fn x, acc ->
      IO.inspect(x)
      FarmProc.step(acc)
    end)
    IO.inspect(farm_proc1)
    raise "Opps"
  end
end

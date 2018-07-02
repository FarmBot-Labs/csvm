defmodule Csvm.ResolverTest do
  use ExUnit.Case, async: true
  alias Csvm.{ Resolver, AST, FarmProc }
  import Csvm.Utils

  def fetch_fixture(fname) do
    File.read!(fname)
      |> Jason.decode!()
      |> AST.decode()
  end

  test "variable resolution" do
    fun = fn x ->
      IO.inspect(x || "NO")
      { :ok, fetch_fixture("fixture/inner_sequence.json") }
    end
    outer_json = fetch_fixture("fixture/outer_sequence.json") |> AST.Slicer.run()
    farm_proc0 = FarmProc.new(fun, addr(0), outer_json)
    farm_proc1 = Enum.reduce(0..6, farm_proc0, fn _, acc ->
      FarmProc.step(acc)
    end)
    IO.puts("THIS IS NOT DONE - RC")
  end
end

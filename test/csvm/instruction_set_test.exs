defmodule Csvm.InstructionSetTest do
  use ExUnit.Case
  alias Csvm.{AST, FarmProc}

  @fixture AST.decode(%{
             kind: :_if,
             args: %{
               lhs: :x,
               op: "is",
               rhs: 10,
               _then: %{kind: :nothing, args: %{}},
               _else: %{kind: :nothing, args: %{}}
             }
           })

  test "Sets the correct `crash_reason`" do
    fun = fn _ -> {:error, "whatever"} end
    heap = AST.slice(@fixture)
    farm_proc = FarmProc.new(fun, Address.new(1), heap)

    waiting = FarmProc.step(farm_proc)
    assert FarmProc.get_status(waiting) == :waiting

    crashed = FarmProc.step(waiting)
    assert FarmProc.get_status(crashed) == :crashed
    assert FarmProc.get_crash_reason(crashed) == "whatever"
  end

  test "_if handles bad interaction layer implementations" do
    fun = fn _ -> :ok end
    heap = AST.slice(@fixture)
    farm_proc = FarmProc.new(fun, Address.new(1), heap)

    assert_raise RuntimeError, "Bad _if implementation.", fn ->
      %{status: :waiting} = farm_proc = FarmProc.step(farm_proc)
      FarmProc.step(farm_proc)
    end
  end

  test "move absolute bad implementation"

  test "execute handles bad interaction layer implementation." do
    fun = fn _ -> {:ok, :not_ast} end
    ast = AST.new(:execute, %{sequence_id: 100}, [])
    heap = AST.slice(ast)
    farm_proc = FarmProc.new(fun, Address.new(1), heap)

    assert_raise RuntimeError, "Bad execute implementation.", fn ->
      %{status: :waiting} = farm_proc = FarmProc.step(farm_proc)
      FarmProc.step(farm_proc)
    end
  end
end

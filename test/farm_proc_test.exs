defmodule Csvm.FarmProcTest do
  use ExUnit.Case
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer
  # alias Csvm.AST.Heap
  alias Csvm.AST.Heap.Address

  test "init a new farm_proc" do
    fun = fn _kind, _args ->
      :ok
    end

    heap = heap()
    farm_proc = FarmProc.new(fun, heap)
    assert FarmProc.get_pc_ptr(farm_proc) == Pointer.new(0, Address.new(1))
    assert FarmProc.get_heap_by_page_addr(farm_proc, 0) == heap
    assert FarmProc.get_return_stack(farm_proc) == []
    assert FarmProc.get_kind(farm_proc, FarmProc.get_pc_ptr(farm_proc)) == :sequence
  end

  test "single step" do
    fun = fn _kind, _args ->
      :ok
    end

    farm_proc = FarmProc.new(fun, heap())
    assert FarmProc.get_kind(farm_proc, FarmProc.get_pc_ptr(farm_proc)) == :sequence
    %FarmProc{} = next = FarmProc.step(farm_proc)
    assert Enum.count(FarmProc.get_return_stack(next)) == 1
    # Next step is a "move_absolute"
    # Next step has a "speed" of 100
  end

  defp heap do
    {:ok, map} = Csvm.TestSupport.Fixtures.master_sequence()
    ast = Csvm.AST.parse(map)
    Csvm.AST.Slicer.run(ast)
  end
end

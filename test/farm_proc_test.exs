defmodule Csvm.FarmProcTest do
  use ExUnit.Case
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer
  alias Csvm.AST
  alias Csvm.AST.Heap.Address

  test "init a new farm_proc" do
    fun = fn _kind, _args ->
      :ok
    end

    heap = heap()
    farm_proc = FarmProc.new(fun, heap)
    assert FarmProc.get_pc_ptr(farm_proc) == Pointer.new(0, Address.new(1))
    assert FarmProc.get_heap_by_page_index(farm_proc, 0) == heap
    assert FarmProc.get_return_stack(farm_proc) == []
    assert FarmProc.get_kind(farm_proc, FarmProc.get_pc_ptr(farm_proc)) == :sequence
  end

  test "get_body_address" do
    farm_proc = FarmProc.new(fn _, _ -> :ok end, heap())
    data = FarmProc.get_body_address(farm_proc, Pointer.new(0, Address.new(1)))
    refute FarmProc.is_null_address?(data)
  end

  test "null address" do
    assert FarmProc.is_null_address?(Pointer.null())
    assert FarmProc.is_null_address?(Address.null())
    assert FarmProc.is_null_address?(Pointer.new(0, Address.new(0)))
    assert FarmProc.is_null_address?(Address.new(0))
    assert FarmProc.is_null_address?(Pointer.new(100, Address.new(0)))
    refute FarmProc.is_null_address?(Pointer.new(100, Address.new(50)))
    refute FarmProc.is_null_address?(Address.new(99))
  end

  test "performs steps" do
    fun = fn _kind, _args ->
      :ok
    end

    step0 = FarmProc.new(fun, heap())
    assert FarmProc.get_kind(step0, FarmProc.get_pc_ptr(step0)) == :sequence
    %FarmProc{} = step1 = FarmProc.step(step0)
    assert Enum.count(FarmProc.get_return_stack(step1)) == 1

    pc_pointer  = FarmProc.get_pc_ptr(step1)
    actual_kind = FarmProc.get_kind(step1, pc_pointer)
    step1_cell  = FarmProc.get_cell_by_address(step1, pc_pointer)
    assert actual_kind == :move_absolute
    assert step1_cell[:speed] == 100

    # Perform "move_abs"
    %FarmProc{} = step2 = FarmProc.step(step1)
    IO.inspect(step2)
    # Make sure side effects are called
    pc_pointer  = FarmProc.get_pc_ptr(step2)
    actual_kind = FarmProc.get_kind(step2, pc_pointer)
    step2_cell  = FarmProc.get_cell_by_address(step2, pc_pointer)
    assert actual_kind        == :move_relative
    assert step2_cell[:y]     == 20
    assert step2_cell[:x]     == 10
    assert step2_cell[:z]     == 30
    assert step2_cell[:speed] == 50
    # Make sure that `Ops.next` is moving correctly.
  end

  test "sequence with no body halts" do
    heap = AST.new(:sequence, %{}, []) |> Csvm.AST.Slicer.run()
    farm_proc = FarmProc.new(fn _, _ -> :ok end, heap)
    assert FarmProc.get_status(farm_proc) == :ok

    # step into the sequence.
    next = FarmProc.step(farm_proc)
    assert FarmProc.get_pc_ptr(next) == Pointer.null()
    assert FarmProc.get_return_stack(next) == []
    assert FarmProc.get_status(next) == :ok

    # Each following step should still be stopped/paused.
    next1 = FarmProc.step(next)
    assert FarmProc.get_pc_ptr(next1) == Pointer.null()
    assert FarmProc.get_return_stack(next1) == []
    assert FarmProc.get_status(next1) == :done

    next2 = FarmProc.step(next1)
    assert FarmProc.get_pc_ptr(next2) == Pointer.null()
    assert FarmProc.get_return_stack(next2) == []
    assert FarmProc.get_status(next2) == :done

    next3 = FarmProc.step(next2)
    assert FarmProc.get_pc_ptr(next3) == Pointer.null()
    assert FarmProc.get_return_stack(next3) == []
    assert FarmProc.get_status(next3) == :done
  end

  defp heap do
    {:ok, map} = Csvm.TestSupport.Fixtures.master_sequence()
    ast = Csvm.AST.parse(map)
    Csvm.AST.Slicer.run(ast)
  end
end

defmodule Csvm.FarmProcTest do
  use ExUnit.Case
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer
  alias Csvm.AST

  test "init a new farm_proc" do
    fun = fn _kind, _args ->
      :ok
    end

    heap = Csvm.TestSupport.Fixtures.heap()
    farm_proc = FarmProc.new(fun, 0, heap)
    assert FarmProc.get_pc_ptr(farm_proc) == Pointer.new(0, Address.new(1))
    assert FarmProc.get_heap_by_page_index(farm_proc, 0) == heap
    assert FarmProc.get_return_stack(farm_proc) == []
    assert FarmProc.get_kind(farm_proc, FarmProc.get_pc_ptr(farm_proc)) == :sequence
  end

  test "io functions crash the vm" do
    fun = fn _ -> {:error, "movement error"} end
    heap = AST.new(:move_relative, %{x: 100, y: 123, z: 0}, []) |> Csvm.AST.Slicer.run()
    step0 = FarmProc.new(fun, 0, heap)
    step1 = FarmProc.step(step0)
    assert FarmProc.get_pc_ptr(step1).page == 0
    assert FarmProc.get_status(step1) == :waiting
    step2 = FarmProc.step(step1)
    assert FarmProc.get_status(step2) == :crashed
    assert FarmProc.get_pc_ptr(step2) == Pointer.null(step1)
  end

  test "io functions bad return values raise runtime exception" do
    fun = fn _ -> {:eroror, 100} end
    heap = AST.new(:move_relative, %{x: 100, y: 123, z: 0}, []) |> Csvm.AST.Slicer.run()
    step0 = FarmProc.new(fun, 0, heap)
    step1 = FarmProc.step(step0)
    assert FarmProc.get_status(step1) == :waiting
    assert Process.alive?(step1.io_latch)
    # require IEx; IEx.pry
    # FarmProc.step(step1)

    assert_raise RuntimeError, "Bad return value: {:eroror, 100}", fn ->
      Process.alive?(step1.io_latch)
      FarmProc.step(step1)
    end
  end

  test "get_body_address" do
    farm_proc = FarmProc.new(fn _ -> :ok end, 0, Csvm.TestSupport.Fixtures.heap())
    data = FarmProc.get_body_address(farm_proc, Pointer.new(0, Address.new(1)))
    refute FarmProc.is_null_address?(data)
  end

  test "null address" do
    farm_proc = FarmProc.new(fn _ -> :ok end, 0, Csvm.TestSupport.Fixtures.heap())
    assert FarmProc.is_null_address?(Pointer.null(farm_proc))
    assert FarmProc.is_null_address?(Address.null())
    assert FarmProc.is_null_address?(Pointer.new(0, Address.new(0)))
    assert FarmProc.is_null_address?(Address.new(0))
    assert FarmProc.is_null_address?(Pointer.new(100, Address.new(0)))
    refute FarmProc.is_null_address?(Pointer.new(100, Address.new(50)))
    refute FarmProc.is_null_address?(Address.new(99))
  end

  test "performs all the steps" do
    this = self()

    always_false_fun = fn ast ->
      send(this, ast)

      case ast.kind do
        :_if -> {:ok, false}
        _ -> :ok
      end
    end

    always_true_fun = fn ast ->
      send(this, ast)

      case ast.kind do
        :_if -> {:ok, true}
        _ -> :ok
      end
    end

    step0 = FarmProc.new(always_false_fun, 2, Csvm.TestSupport.Fixtures.heap())
    assert FarmProc.get_kind(step0, FarmProc.get_pc_ptr(step0)) == :sequence
    %FarmProc{} = step1 = FarmProc.step(step0)
    assert Enum.count(FarmProc.get_return_stack(step1)) == 1

    pc_pointer = FarmProc.get_pc_ptr(step1)
    actual_kind = FarmProc.get_kind(step1, pc_pointer)
    step1_cell = FarmProc.get_cell_by_address(step1, pc_pointer)
    assert actual_kind == :move_absolute
    assert step1_cell[:speed] == 100

    # Perform "move_abs"
    %FarmProc{} = %{status: :waiting} = step1 = FarmProc.step(step1)
    %FarmProc{} = step2 = FarmProc.step(step1)
    # Make sure side effects are called
    pc_pointer = FarmProc.get_pc_ptr(step2)
    actual_kind = FarmProc.get_kind(step2, pc_pointer)
    step2_cell = FarmProc.get_cell_by_address(step2, pc_pointer)
    assert actual_kind == :move_relative
    assert step2_cell[:x] == 10
    assert step2_cell[:y] == 20
    assert step2_cell[:z] == 30
    assert step2_cell[:speed] == 50
    # Test side effects.

    assert_receive %Csvm.AST{
      args: %{
        location: %Csvm.AST{
          args: %{pointer_id: 1, pointer_type: "Plant"},
          kind: :point
        },
        offset: %Csvm.AST{
          args: %{x: 10, y: 20, z: -30},
          kind: :coordinate
        },
        speed: 100
      },
      kind: :move_absolute
    }

    # Make sure that `Ops.next` is moving correctly.
    %FarmProc{} = step3 = FarmProc.step(step2)

    assert_receive %Csvm.AST{
      kind: :move_relative,
      comment: nil,
      args: %{
        x: 10,
        y: 20,
        z: 30,
        speed: 50
      }
    }

    %FarmProc{} = step4 = FarmProc.step(step3)

    assert_receive %Csvm.AST{
      kind: :write_pin,
      args: %{
        pin_number: 0,
        pin_value: 0,
        pin_mode: 0
      }
    }

    %FarmProc{} = step5 = FarmProc.step(step4)

    assert_receive %Csvm.AST{
      kind: :write_pin,
      args: %{
        pin_mode: 0,
        pin_value: 1,
        pin_number: %Csvm.AST{
          kind: :named_pin,
          args: %{
            pin_type: "Peripheral",
            pin_id: 5
          }
        }
      }
    }

    %FarmProc{} = step6 = FarmProc.step(step5)

    assert_receive %Csvm.AST{
      kind: :read_pin,
      args: %{
        pin_mode: 0,
        label: "---",
        pin_number: 0
      }
    }

    %FarmProc{} = step7 = FarmProc.step(step6)

    assert_receive %Csvm.AST{
      kind: :read_pin,
      args: %{
        pin_mode: 1,
        label: "---",
        pin_number: %Csvm.AST{
          kind: :named_pin,
          args: %{
            pin_type: "Sensor",
            pin_id: 1
          }
        }
      }
    }

    %FarmProc{} = step8 = FarmProc.step(step7)

    assert_receive %Csvm.AST{
      kind: :wait,
      args: %{
        milliseconds: 100
      }
    }

    %FarmProc{} = step9 = FarmProc.step(step8)

    assert_receive %Csvm.AST{
      kind: :send_message,
      args: %{
        message: "FarmBot is at position {{ x }}, {{ y }}, {{ z }}.",
        message_type: "success"
      },
      body: [
        %Csvm.AST{kind: :channel, args: %{channel_name: "toast"}},
        %Csvm.AST{kind: :channel, args: %{channel_name: "email"}},
        %Csvm.AST{kind: :channel, args: %{channel_name: "espeak"}}
      ]
    }

    %FarmProc{} = step10 = FarmProc.step(step9)

    assert_receive %Csvm.AST{
      kind: :find_home,
      args: %{
        speed: 100,
        axis: "all"
      }
    }

    # Step 10, but _if is false -> nothing
    %FarmProc{} = step11_false = FarmProc.step(step10)
    next_pc_ptr = FarmProc.get_pc_ptr(step11_false)
    assert FarmProc.get_kind(step11_false, next_pc_ptr) == :nothing

    # Step 10, but _if is true -> execute
    step10_mod = replace_sys_call_fun(step10, always_true_fun)
    %FarmProc{} = step11_true = FarmProc.step(step10_mod)
    next_pc_ptr = FarmProc.get_pc_ptr(step11_true)
    assert FarmProc.get_kind(step11_true, next_pc_ptr) == :execute
  end

  test "nonrecursive execute" do
    seq2 = AST.new(:sequence, %{}, [AST.new(:wait, %{milliseconds: 100}, [])])
    main_seq = AST.new(:sequence, %{}, [AST.new(:execute, %{sequence_id: 2}, [])])
    initial_heap = AST.Slicer.run(main_seq)

    fun = fn ast ->
      if ast.kind == :execute do
        {:ok, seq2}
      else
        :ok
      end
    end

    step0 = FarmProc.new(fun, 1, initial_heap)
    assert FarmProc.get_heap_by_page_index(step0, 1)

    assert_raise RuntimeError, ~r(page), fn ->
      FarmProc.get_heap_by_page_index(step0, 2)
    end

    step1 = FarmProc.step(step0)
    %{status: :waiting} = step1 = FarmProc.step(step1)
    step2 = FarmProc.step(step1)
    assert FarmProc.get_heap_by_page_index(step2, 2)
    [ptr1, ptr2] = FarmProc.get_return_stack(step2)
    assert ptr1 == Pointer.new(1, Address.new(0))
    assert ptr2 == Pointer.new(1, Address.new(0))

    step3 = FarmProc.step(step2)
    [ptr3 | _] = FarmProc.get_return_stack(step3)
    assert ptr3 == Pointer.new(2, Address.new(0))

    step4 = FarmProc.step(step3)
    step5 = FarmProc.step(step4)
    step6 = FarmProc.step(step5)
    step7 = FarmProc.step(step6)
    assert FarmProc.get_return_stack(step7) == []
    assert FarmProc.get_pc_ptr(step7) == Pointer.null(step7)
  end

  test "raises when trying to step thru a crashed proc" do
    heap = AST.new(:execute, %{sequence_id: 100}, []) |> AST.Slicer.run()
    fun = fn _ -> {:error, "could not find sequence"} end
    step0 = FarmProc.new(fun, 1, heap)
    waiting = FarmProc.step(step0)
    crashed = FarmProc.step(waiting)
    assert FarmProc.get_status(crashed) == :crashed

    assert_raise RuntimeError, "Tried to step with crashed process!", fn ->
      FarmProc.step(crashed)
    end
  end

  test "recursive sequence" do
    sequence_5 = AST.new(:sequence, %{}, [AST.new(:execute, %{sequence_id: 5}, [])])

    fun = fn ast ->
      if ast.kind == :execute do
        {:error, "Should already be cached."}
      else
        :ok
      end
    end

    heap = AST.Slicer.run(sequence_5)
    step0 = FarmProc.new(fun, 5, heap)

    step1 = FarmProc.step(step0)
    assert Enum.count(FarmProc.get_return_stack(step1)) == 1

    step2 = FarmProc.step(step1)
    assert Enum.count(FarmProc.get_return_stack(step2)) == 2

    step3 = FarmProc.step(step2)
    assert Enum.count(FarmProc.get_return_stack(step3)) == 3

    pc = FarmProc.get_pc_ptr(step3)
    zero_page_num = FarmProc.get_zero_page_num(step3)
    assert pc.page == zero_page_num

    step999 =
      Enum.reduce(0..996, step3, fn _, acc ->
        FarmProc.step(acc)
      end)

    assert_raise RuntimeError, "Too many reductions!", fn ->
      FarmProc.step(step999)
    end
  end

  test "raises an exception when no implementation is found for a `kind`" do
    heap = AST.new(:sequence, %{}, [AST.new(:fire_laser, %{}, [])]) |> Csvm.AST.Slicer.run()

    assert_raise RuntimeError, "No implementation for: fire_laser", fn ->
      step_0 = FarmProc.new(fn _ -> :ok end, 0, heap)
      step_1 = FarmProc.step(step_0)
      _step_2 = FarmProc.step(step_1)
    end
  end

  test "sequence with no body halts" do
    heap = AST.new(:sequence, %{}, []) |> Csvm.AST.Slicer.run()
    farm_proc = FarmProc.new(fn _ -> :ok end, 0, heap)
    assert FarmProc.get_status(farm_proc) == :ok

    # step into the sequence.
    next = FarmProc.step(farm_proc)
    assert FarmProc.get_pc_ptr(next) == Pointer.null(next)
    assert FarmProc.get_return_stack(next) == []

    # Each following step should still be stopped/paused.
    next1 = FarmProc.step(next)
    assert FarmProc.get_pc_ptr(next1) == Pointer.null(next1)
    assert FarmProc.get_return_stack(next1) == []

    next2 = FarmProc.step(next1)
    assert FarmProc.get_pc_ptr(next2) == Pointer.null(next2)
    assert FarmProc.get_return_stack(next2) == []

    next3 = FarmProc.step(next2)
    assert FarmProc.get_pc_ptr(next3) == Pointer.null(next3)
    assert FarmProc.get_return_stack(next3) == []
  end

  defp replace_sys_call_fun(%FarmProc{} = farm_proc, fun) when is_function(fun) do
    %FarmProc{farm_proc | sys_call_fun: fun}
  end
end

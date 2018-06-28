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

    heap = Csvm.TestSupport.Fixtures.heap()
    farm_proc = FarmProc.new(fun, heap)
    assert FarmProc.get_pc_ptr(farm_proc) == Pointer.new(0, Address.new(1))
    assert FarmProc.get_heap_by_page_index(farm_proc, 0) == heap
    assert FarmProc.get_return_stack(farm_proc) == []
    assert FarmProc.get_kind(farm_proc, FarmProc.get_pc_ptr(farm_proc)) == :sequence
  end

  test "get_body_address" do
    farm_proc = FarmProc.new(fn _, _ -> :ok end, Csvm.TestSupport.Fixtures.heap())
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
    this = self()

    fun = fn ast ->
      send(this, ast)
      :ok
    end

    step0 = FarmProc.new(fun, Csvm.TestSupport.Fixtures.heap())
    assert FarmProc.get_kind(step0, FarmProc.get_pc_ptr(step0)) == :sequence
    %FarmProc{} = step1 = FarmProc.step(step0)
    assert Enum.count(FarmProc.get_return_stack(step1)) == 1

    pc_pointer = FarmProc.get_pc_ptr(step1)
    actual_kind = FarmProc.get_kind(step1, pc_pointer)
    step1_cell = FarmProc.get_cell_by_address(step1, pc_pointer)
    assert actual_kind == :move_absolute
    assert step1_cell[:speed] == 100

    # Perform "move_abs"
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
end

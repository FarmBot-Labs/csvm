defmodule CsvmTest do
  use ExUnit.Case
  alias Csvm.{AST, FarmProc}
  @master_sequence File.read!("fixture/master_sequence.json") |> Jason.decode!()

  setup do
    fun = fn ast ->
      case ast.kind do
        :_if ->
          {:ok, true}

        :execute ->
          {:ok, AST.new(:sequence, %{}, [])}

        _ ->
          :ok
      end
    end

    {:ok, csvm} = Csvm.start_link([io_layer: fun], [])
    {:ok, %{csvm: csvm}}
  end

  test "master sequence", %{csvm: vm} do
    id = Csvm.queue(vm, @master_sequence, 2)
    proc = Csvm.await(vm, id)
    refute FarmProc.get_status(proc) == :ok
  end

  test "won't try to start bad celeryscript", %{csvm: vm} do
    assert_raise RuntimeError, "Bad ast: %{not_valid: :celeryscript}", fn ->
      Csvm.queue(vm, %{not_valid: :celeryscript}, 1)
    end
  end

  test "bad io causes crash" do
    ast = AST.new(:wait, %{milliseconds: 10000}, [])

    fun = fn _ast ->
      {:error, "uh oh"}
    end

    {:ok, csvm} = Csvm.start_link([io_layer: fun], [])
    id = Csvm.queue(csvm, ast, 0)
    proc = Csvm.await(csvm, id)
    assert FarmProc.get_status(proc) == :crashed
    assert FarmProc.get_crash_reason(proc) == "uh oh"
  end

  test "loopup after garbage collection ", %{csvm: vm} do
    body = [
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, [])
    ]

    ast = AST.new(:sequence, %{}, body)
    id0 = Csvm.queue(vm, ast, 0)
    proc_0 = Csvm.await(vm, id0)
    assert FarmProc.get_status(proc_0) == :done
    :ok = Csvm.sweep(vm)

    assert_raise RuntimeError, "no job by that identifier", fn ->
      Csvm.await(vm, id0)
    end
  end

  test "stepping on a crashed vm", %{csvm: vm} do
    fun = fn _ast ->
      {:error, "whoops!"}
    end

    :sys.replace_state(vm, fn state ->
      Map.put(state, :io_layer, fun)
    end)

    body = [AST.new(:wait, %{}, [])]
    ast = AST.new(:sequence, %{}, body)
    id = Csvm.queue(vm, ast, 0)
    :ok = Csvm.force_cycle(vm)

    proc = Csvm.await(vm, id)
    assert FarmProc.get_status(proc) == :crashed
    assert FarmProc.get_crash_reason(proc) == "whoops!"
  end

  test "garbage collection", %{csvm: vm} do
    body = [
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, [])
    ]

    ast = AST.new(:sequence, %{}, body)
    id0 = Csvm.queue(vm, ast, 0)
    id1 = Csvm.queue(vm, ast, 1)
    id2 = Csvm.queue(vm, ast, 2)

    proc_0 = Csvm.await(vm, id0)
    proc_1 = Csvm.await(vm, id1)
    proc_2 = Csvm.await(vm, id2)

    assert FarmProc.get_status(proc_0) == :done
    assert FarmProc.get_status(proc_1) == :done
    assert FarmProc.get_status(proc_2) == :done

    :ok = Csvm.sweep(vm)
    assert map_size(:sys.get_state(vm).procs.items) == 0
  end

  test "garbage collection only clears complete procs", %{csvm: vm} do
    body = [
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, []),
      AST.new(:wait, %{}, [])
    ]

    ast = AST.new(:sequence, %{}, body)

    fun = fn _ast ->
      Process.sleep(100)
      :ok
    end

    :sys.replace_state(vm, fn state ->
      Map.put(state, :io_layer, fun)
    end)

    assert :sys.get_state(vm).io_layer == fun

    id = Csvm.queue(vm, ast, 10)
    :ok = Csvm.sweep(vm)
    assert map_size(:sys.get_state(vm).procs.items) == 1
    proc = Csvm.await(vm, id)
    assert FarmProc.get_status(proc) == :done
    :ok = Csvm.sweep(vm)
    assert map_size(:sys.get_state(vm).procs.items) == 0
  end
end

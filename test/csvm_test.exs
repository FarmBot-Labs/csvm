defmodule CsvmTest do
  use ExUnit.Case
  alias Csvm.{AST, FarmProc}
  @master_sequence File.read!("fixture/master_sequence.json") |> Jason.decode!()

  setup do
    fun = fn ast ->
      case ast.kind do
        :_if -> {:ok, true}
        :execute ->
          {:ok, AST.new(:sequence, %{}, [])}
        _ -> :ok
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

  test "runtime exceptions in the vm are caught."
end

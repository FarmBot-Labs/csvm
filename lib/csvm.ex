defmodule Csvm do
  alias Csvm.{AST, FarmProc}
  defstruct [:farm_proc]

  @spec new(integer, Ast.t(), function) :: map
  def new(fun, zero_page_num, %AST{} = program) do
    heap      = Csvm.AST.Slicer.run(program)
    farm_proc = FarmProc.new(fun, zero_page_num, heap)
    %__MODULE__{ farm_proc: farm_proc }
  end

  def execute(server_pid, vm)
    { :ok, proc_id } = GenServer.call(server_pid, {:add_vm, vm})
    GenServer.call(server_pid, { :await, proc_id })
  end
end

defmodule Csvm.Server do
  use GenServer
  defstruct [:vms, :next_proc_id]

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, %__MODULE__{ vms: %{}, next_proc_id: 0 }}
  end

  def handle_call({:add_vm, %Csvm{} = vm}, _from, state) do
    next_state1 = bump_proc_id(state)
    next_state2 = add_vm(next_state1, state.next_proc_id, vm)

    {:reply, {:ok, next_state2.next_proc_id}, next_state2}
  end

  def handle_call({:await, _}, _from, state) do
  end

  def run_vm(%Csvm{} = csvm, ) do
  end

  @spec bump_proc_id(Server.t()) :: Server.t()
  defp bump_proc_id(state) do
    %Server{ state | next_proc_id: state.next_proc_id + 1 }
  end

  defp add_vm(state, id, vm) do
    %Server{ state | vms: Map.put(state.vms, id, vm) }
  end
end

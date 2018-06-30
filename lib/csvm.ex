defmodule Csvm do
end

#
#   use GenServer
#   @tick_ms 500
#   defstruct [:procs, :next_proc_id, :tick]
#
#   @spec new(integer, Ast.t(), function) :: map
#   def new(fun, zero_page_num, %AST{} = program) do
#     heap = Csvm.AST.Slicer.run(program)
#     farm_proc = FarmProc.new(fun, zero_page_num, heap)
#     GenServer.call(server_pid, {:add_proc, farm_proc}
#   end
#
#   def execute(server_pid, reference) do
#     :ok = GenServer.call(server_pid, {:execute, reference})
#     wait_until_finish(server_pid, reference)
#   end
#
#   def start_link(args) do
#     GenServer.start_link(__MODULE__, args)
#   end
#
#   def init([]) do
#     tick = start_tick(self())
#     {:ok, %__MODULE__{procs: %{}, next_proc_id: 0, tick: tick}}
#   end
#
#   def handle_call({:add_proc, farm_proc}, _from, state) do
#     state = bump_proc_id(state)
#     state = add_proc(state, state.next_proc_id, farm_proc)
#     {:reply, {:ok, state.next_proc_id}, state}
#   end
#
#   def handle_call({:check_status, proc_id}, _from, state) do
#     proc = state.procs[proc_id]
#     if proc do
#       {:reply, FarmProc.get_status(proc), state}
#     else
#       {:reply, {:error, :no_proc}, state}
#     end
#   end
#
#   def handle_call({:execute, proc_id}, _from, state) do
#     proc = state.procs[proc_id]
#     if proc do
#       {:reply, :ok, state}
#     else
#       {:reply, {:error, :no_proc}, state}
#     end
#   end
#
#   defp wait_until_finish(server_pid, vm) do
#     case GenServer.call(server_pid, {:check_status, vm}) do
#       :done -> :done
#       :running -> wait_until_finish(server_pid, vm)
#       {:crashed, reason} -> {:error, reason}
#     end
#   end
#
#   @spec bump_proc_id(Server.t()) :: Server.t()
#   defp bump_proc_id(state) do
#     %Server{state | next_proc_id: state.next_proc_id + 1}
#   end
#
#   defp add_proc(state, id, proc) do
#     %Server{state | vms: Map.put(state.procs, id, proc)}
#   end
#
#   defp start_tick(pid) do
#     Process.send_after(self(), {:tick, :os.system_time()}, @tick_ms)
#   end
# end

defmodule Csvm.SysCallHandler do
  use GenServer
  @type ast :: Csvm.AST.t()
  @type return_value :: :ok | {:ok, any} | {:error, String.t()}
  @type sys_call_fun :: (ast -> return_value)

  @spec apply_sys_call_fun(sys_call_fun, ast) :: return_value | no_return
  def apply_sys_call_fun(fun, ast) do
    {:ok, sys_call} = GenServer.start_link(__MODULE__, [fun, ast])
    Process.link(sys_call)
    sys_call
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def get_status(sys_call) do
    GenServer.call(sys_call, :get_status)
  end

  def get_results(sys_call) do
    GenServer.call(sys_call, :get_results)
  end

  def init([fun, ast]) do
    # Process.flag(:trap_exit, true)
    # pid = spawn __MODULE__, :do_apply, [fun, ast]
    # pid = self()
    {:ok, %{status: :ok, results: nil, pid: nil}}
  end

  def terminate(reason, state) do
    IO.puts "WHOOPS???: #{inspect reason}"
  end

  # def handle_info({:EXIT, _, :process, reason}, state) do
  #   {:noreply, %{state | status: :complete, results: reason}}
  # end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:get_results, _from, state) do
    results = state.result || raise("oh no")
    {:reply, results, state}
  end

  def do_apply(fun, ast) do
    exit(apply(fun, [ast]))
  end
end

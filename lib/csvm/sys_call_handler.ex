defmodule Csvm.SysCallHandler do
  use GenServer
  @type ast :: Csvm.AST.t()
  @type return_value :: :ok | {:ok, any} | {:error, String.t()}
  @type sys_call_fun :: (ast -> return_value)

  @spec apply_sys_call_fun(sys_call_fun, ast) :: return_value | no_return
  def apply_sys_call_fun(fun, ast) do
    {:ok, sys_call} = GenServer.start_link(__MODULE__, [fun, ast])
    sys_call
  end

  def get_status(sys_call) do
    GenServer.call(sys_call, :get_status)
  end

  def get_results(sys_call) do
    GenServer.call(sys_call, :get_results)
  end

  def init([fun, ast]) do
    pid = spawn_monitor __MODULE__, :do_apply, [fun, ast]
    {:ok, %{status: :ok, results: nil, pid: pid}}
  end

  def terminate(reason, state) do
    IO.puts "WHOOPS???: #{inspect reason}"
  end

  def handle_info({:DOWN, _ref, :process, _pid, info}, %{pid: pid} = state) do
    {:noreply, %{state | results: info, status: :complete}}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:get_results, _from, %{results: nil} = state) do
    {:stop, "no results", state}
  end

  def handle_call(:get_results, _from, %{results: results} = state) do
    {:stop, :normal, results, state}
  end

  def do_apply(fun, ast) do
    exit(apply(fun, [ast]))
  end
end

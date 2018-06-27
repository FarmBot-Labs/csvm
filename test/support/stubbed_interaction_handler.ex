defmodule StubbedInteractionHandler do
  @behaviour Csvm.InteractionHandler
  use GenServer

  def take_photo(priv_data) do
    GenServer.call(priv_data.pid, {:last_call, :take_photo, []})
    {:ok, priv_data }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def get_last_call(pid) do
    GenServer.call(pid, :get_last_call)
  end

  def init(_) do
    {:ok, %{last_call: %{fn_name: nil, fn_args: nil}}}
  end

  def handle_call({:last_call, fn_name, args}, _from, state) do
    call_data  = %{ fn_name: fn_name, fn_args: args }
    next_state = Map.put(state, :last_call, call_data)
    {:reply, call_data, next_state}
  end

  def handle_call(:get_last_call, _from, state) do
    {:reply, state.last_call, state}
  end
end

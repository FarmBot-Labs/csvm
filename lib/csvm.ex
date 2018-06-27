defmodule Csvm do
  use GenServer
  alias __MODULE__, as: State
  defstruct [:interaction_handler]

  def interpret(pid \\ __MODULE__, ast) do
    GenServer.call(pid, {:interpret, ast})
  end

  def async_interpret(pid \\ __MODULE__, ast) do
    GenServer.call(pid, {:async_interpret, ast})
  end

  def await(pid \\ __MODULE__, ref) do
    GenServer.call(pid, {:await, ref})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(interaction_handler_module) do
    {:ok, %State{interaction_handler: interaction_handler_module}}
  end

  def handle_call({:interpret, ast}, _from, state) do
    IO.puts("Hey :wave:")
    {:reply, 123, state}
  end

  def handle_call({:async_interpret, ast}, from, state) do
    IO.puts("Hey :wave: 123")
    GenServer.reply(from, :woo)
    {:noreply, state}
  end
end

defmodule Csvm do
  use GenServer
  alias Csvm.State
  import State, only: [
    {:incr_count, 1}
    {:add_code, 2}
  ]

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
    {:ok, %State{
      counter:             0,
      code_pointer:        2,
      instr_pointer:       6,
      interaction_handler: interaction_handler_module,
      code: %{}
    }}
  end

  def handle_call({:interpret, ast}, _from, state) do
    IO.puts("Hey :wave:")
    next_state1 = state |> incr_count() |> add_code(ast)
    next_state2 = jump(next_state1, next_state1.counter)
    {:reply, 123, next_state}
  end

  def handle_call({:async_interpret, ast}, from, state) do
    IO.puts("Hey :wave: 123")
    GenServer.reply(from, :woo)
    {:noreply, state}
  end
end

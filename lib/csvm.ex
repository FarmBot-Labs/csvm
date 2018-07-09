defmodule Csvm do
  use GenServer
  alias Csvm.{AST, FarmProc}

  defstruct procs: %{},
            counter: 0,
            io_layer: nil,
            timer: nil

  @opaque job_id :: reference
  @doc """
  queue an AST for execution in the VM.
  non-blocking, requires polling from caller.
  """
  @spec queue(GenServer.server(), AST.t(), integer) :: job_id
  def queue(pid \\ __MODULE__, ast, page_id) do
    GenServer.call(pid, {:queue, ast, page_id})
  end

  @doc """
  Blocking version of  queue/1
  """
  @spec await(job_id) :: any
  def await(job_id) do
    raise "Not impl."
  end

  def do_step(%FarmProc{} = fp) do
  end

  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    timer = start_timer(self())
    {:ok, %Csvm{io_layer: Keyword.fetch!(args, :io_layer), timer: timer}}
  end

  def handle_call({:queue, ast, page_id}, _from, %Csvm{} = state) do
    proc = FarmProc.new(state.io_layer, Address.new(page_id), ast)
    counter = state.counter + 1
    next_state1 = %{state | counter: counter}
    next_state2 = %{next_state1 | procs: Map.put(state.procs, counter, proc)}
    {:reply, counter, next_state2}
  end

  def handle_info(:tock, state) do
    raise "TODO"
  end

  def start_timer(pid, timeout \\ 200) do
    Process.send_after(pid, :tock, timeout)
  end
end

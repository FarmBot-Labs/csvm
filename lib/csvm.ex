defmodule Csvm do
  use GenServer
  alias Csvm.{AST, FarmProc}
  alias AST.Heap

  @tick_timeout 20

  defstruct [:procs, :io_layer, :tick_timer]

  @opaque job_id :: CircularList.index()

  @doc """
  queue an AST for execution in the VM.
  non-blocking, requires polling from caller.
  """
  @spec queue(GenServer.server(), map, integer) :: job_id | no_return()
  def queue(pid \\ __MODULE__, %{} = map, page_id) when is_integer(page_id) do
    %AST{} = ast = AST.decode(map)
    %Heap{} = heap = AST.slice(ast)
    GenServer.call(pid, {:queue, heap, page_id})
  end

  @doc """
  Blocking version of queue/1
  """
  @spec await(GenServer.server(), job_id) :: FarmProc.t()
  def await(pid \\ __MODULE__, job_id) do
    case GenServer.call(pid, {:lookup, job_id}) do
      %FarmProc{} = proc ->
        case FarmProc.get_status(proc) do
          status when status in [:ok, :waiting] ->
            Process.sleep(@tick_timeout * 2)
            await(pid, job_id)

          _ ->
            proc
        end

      _ ->
        raise("no job by that identifier")
    end
  end

  @spec sweep(GenServer.server()) :: :ok
  def sweep(pid \\ __MODULE__) do
    GenServer.call(pid, :sweep)
  end

  @spec force_cycle(GenServer.server()) :: :ok
  def force_cycle(pid \\ __MODULE__) do
    GenServer.call(pid, :force_cycle)
  end

  @spec start_link(Keyword.t(), GenServer.options()) :: GenServer.server()
  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  # TODO(Connor) - trap_exits so one proc can't crash _all_ procs.

  def init(args) do
    timer = start_tick(self())

    {:ok,
     %Csvm{
       io_layer: Keyword.fetch!(args, :io_layer),
       tick_timer: timer,
       procs: CircularList.new()
     }}
  end

  def handle_call({:queue, %Heap{} = heap, page_id}, _from, %Csvm{} = state) do
    proc = FarmProc.new(state.io_layer, Address.new(page_id), heap)
    new_procs = CircularList.push(state.procs, proc)
    {:reply, CircularList.get_index(new_procs), %Csvm{state | procs: new_procs}}
  end

  def handle_call({:lookup, id}, _from, %Csvm{} = state) do
    {:reply, CircularList.at(state.procs, id), state}
  end

  def handle_call(:force_cycle, _, %Csvm{} = state) do
    _ = stop_tick(state.tick_timer)
    new_timer = start_tick(self(), 0)
    {:reply, :ok, %Csvm{state | tick_timer: new_timer}}
  end

  def handle_call(:sweep, _from, %Csvm{} = state) do
    _ = stop_tick(state.tick_timer)

    new_procs =
      CircularList.reduce(state.procs, fn {index, old}, acc ->
        case FarmProc.get_status(old) do
          :done -> Map.delete(acc, index)
          _ -> Map.put(acc, index, old)
        end
      end)

    new_timer = start_tick(self())

    {:reply, :ok, %Csvm{state | tick_timer: new_timer, procs: new_procs}}
  end

  def handle_info(:tock, state) do
    new_procs =
      if CircularList.is_empty?(state.procs) do
        state.procs
      else
        state.procs
        |> CircularList.rotate()
        |> CircularList.update_current(&do_step(&1))
      end

    # make sure to update the timer _AFTER_ we tick.
    new_timer = start_tick(self())
    {:noreply, %Csvm{state | procs: new_procs, tick_timer: new_timer}}
  end

  defp start_tick(pid, timeout \\ @tick_timeout),
    do: Process.send_after(pid, :tock, timeout)

  defp stop_tick(timer), do: Process.cancel_timer(timer)

  def do_step(%FarmProc{status: :crashed} = farm_proc), do: farm_proc
  def do_step(%FarmProc{} = farm_proc), do: FarmProc.step(farm_proc)
end

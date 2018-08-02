defmodule Csvm do
  use GenServer
  alias Csvm.{AST, FarmProc, ProcStorage}
  import Csvm.Utils
  alias AST.Heap
  require Logger

  @tick_timeout 20

  defstruct [
    :proc_storage,
    :hyper_state,
    :process_io_layer,
    :hyper_io_layer,
    :tick_timer
  ]

  @opaque job_id :: CircularList.index()

  def rpc_request(pid \\ __MODULE__, id \\ -1, %{} = map, fun)
      when is_function(fun) do
    case GenServer.call(pid, {:lookup, id}) do
      %FarmProc{} ->
        rpc_request(pid, id - 1, map, fun)

      nil ->
        job = queue(pid, map, -1)
        proc = await(pid, job)

        case FarmProc.get_status(proc) do
          :done ->
            apply_callback(fun, [:ok])

          :crashed ->
            apply_callback(fun, [{:error, FarmProc.get_crash_reason(proc)}])
        end
    end
  end

  def sequecne(pid \\ __MODULE__, %{} = map, id, fun)
      when is_function(fun) do
    job = queue(pid, map, id)

    spawn(fn ->
      proc = await(pid, job)

      case FarmProc.get_status(proc) do
        :done ->
          apply_callback(fun, :ok)

        :crashed ->
          apply_callback(fun, {:error, FarmProc.get_crash_reason(proc)})
      end
    end)
  end

  @spec queue(GenServer.server(), map, integer) :: job_id
  defp queue(pid, %{} = map, page_id) when is_integer(page_id) do
    case AST.decode(map) do
      %AST{kind: :rpc_request, body: [%AST{kind: :emergency_lock}]} ->
        GenServer.call(pid, :emergency_lock)

      %AST{kind: :rpc_request, body: [%AST{kind: :emergency_unlock}]} ->
        GenServer.call(pid, :emergency_unlock)

      %AST{kind: :emergency_lock} ->
        GenServer.call(pid, :emergency_lock)

      %AST{kind: :emergency_unlock} ->
        GenServer.call(pid, :emergency_unlock)

      %AST{} = ast ->
        %Heap{} = heap = AST.slice(ast)
        %Address{} = page = addr(page_id)
        GenServer.call(pid, {:queue, heap, page})
    end
  end

  @spec await(GenServer.server(), job_id) :: FarmProc.t()
  defp await(pid, job_id) do
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

  @spec force_cycle(GenServer.server()) :: :ok
  def force_cycle(pid \\ __MODULE__) do
    GenServer.call(pid, :force_cycle)
  end

  @doc """
  Start a CSVM monitor.

  ## Required params:
  * `process_io_layer` ->
    function that takes an AST whenever a FarmProc needs IO operations.
  * `hyper_io_layer`
    function that takes one of the hyper calls
  """
  @spec start_link(Keyword.t(), GenServer.name()) :: GenServer.server()
  def start_link(args, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, Keyword.put(args, :name, name), name: name)
  end

  def init(args) do
    timer = start_tick(self())
    storage = ProcStorage.new(Keyword.fetch!(args, :name))
    io_fun = Keyword.fetch!(args, :process_io_layer)
    unless is_function(io_fun), do: raise(ArgumentError)

    {:ok,
     %Csvm{
       process_io_layer: io_fun,
       hyper_io_layer: Keyword.fetch!(args, :hyper_io_layer),
       tick_timer: timer,
       proc_storage: storage
     }}
  end

  def handle_call(:emergency_lock, _from, state) do
    apply_callback(state.hyper_io_layer, [:emergency_lock])
    {:reply, :ok, %{state | hyper_state: :emergency_lock}}
  end

  def handle_call(:emergency_unlock, _from, state) do
    apply_callback(state.hyper_io_layer, [:emergency_unlock])
    {:reply, :ok, %{state | hyper_state: :emergency_unlock}}
  end

  def handle_call(
        {:queue, %Heap{} = heap, %Address{} = page},
        _from,
        %Csvm{} = state
      ) do
    %FarmProc{} = new_proc = FarmProc.new(state.process_io_layer, page, heap)
    :ok = ProcStorage.insert(state.proc_storage, new_proc)
    {:reply, ProcStorage.current_index(state.proc_storage), state}
  end

  def handle_call({:lookup, id}, _from, %Csvm{} = state) do
    case ProcStorage.lookup(state.proc_storage, id) do
      %FarmProc{status: :crashed} = proc ->
        ProcStorage.delete(state.proc_storage, id)
        {:reply, proc, state}

      reply ->
        {:reply, reply, state}
    end
  end

  def handle_call(:force_cycle, _, %Csvm{} = state) do
    _ = stop_tick(state.tick_timer)
    new_timer = start_tick(self(), 0)
    {:reply, :ok, %Csvm{state | tick_timer: new_timer}}
  end

  def handle_info(:tock, state) do
    ProcStorage.update(state.proc_storage, &do_step/1)
    # make sure to update the timer _AFTER_ we tick.
    new_timer = start_tick(self())
    {:noreply, %Csvm{state | tick_timer: new_timer}}
  end

  defp start_tick(pid, timeout \\ @tick_timeout),
    do: Process.send_after(pid, :tock, timeout)

  defp stop_tick(timer), do: Process.cancel_timer(timer)

  @doc false
  def do_step(%FarmProc{status: :crashed} = farm_proc), do: farm_proc

  def do_step(%FarmProc{} = farm_proc) do
    try do
      FarmProc.step(farm_proc)
    rescue
      ex in FarmProc.Error ->
        ex.farm_proc

      ex ->
        farm_proc
        |> FarmProc.set_status(:crashed)
        |> FarmProc.set_crash_reason(Exception.message(ex))
    end
  end

  defp apply_callback(fun, results) when is_function(fun) do
    try do
      _ = apply(fun, results)
    rescue
      ex ->
        Logger.error("Error executing csvm callback: #{Exception.message(ex)}")
    end
  end
end

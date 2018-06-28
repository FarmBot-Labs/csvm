defmodule Csvm.InstructionSet do
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer

  defmodule Ops do
    @spec call(FarmProc.t(), Pointer.t()) :: FarmProc.t()
    def call(%FarmProc{} = farm_proc, %Pointer{} = address) do
      farm_proc
      |> FarmProc.push_rs(FarmProc.get_pc_ptr(farm_proc))
      |> FarmProc.set_pc_ptr(address)
    end

    @spec return(FarmProc.t()) :: FarmProc.t()
    def return(%FarmProc{} = farm_proc) do
      {value, farm_proc} = FarmProc.pop_rs(farm_proc)
      FarmProc.set_pc_ptr(farm_proc, value)
    end

    @spec next(FarmProc.t()) :: FarmProc.t()
    def next(%FarmProc{} = farm_proc) do
      current_pc = FarmProc.get_pc_ptr(farm_proc)
      next_ptr   = FarmProc.get_next_address(farm_proc, current_pc)
      FarmProc.set_pc_ptr(farm_proc, next_ptr)
    end

    @spec next_or_return(FarmProc.t()) :: FarmProc.t()
    def next_or_return(farm_proc) do
      pc_ptr = FarmProc.get_pc_ptr(farm_proc)
      addr   = FarmProc.get_next_address(farm_proc, pc_ptr)
      if FarmProc.is_null_address?(addr) do
        Ops.return(farm_proc)
      else
        Ops.next(farm_proc)
      end
    end

    def crash(farm_proc, reason) do
      raise("VM Crashed: " <> reason )
    end
  end

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = farm_proc) do
    body_addr = FarmProc.get_body_address(farm_proc, FarmProc.get_pc_ptr(farm_proc))
    IO.inspect(body_addr)

    if FarmProc.is_null_address?(body_addr) do
      IO.puts("This sequence has no body. Exiting.")
      Ops.return(farm_proc)
    else
      IO.puts("This sequence has a body. Entering: #{inspect(body_addr)}")
      Ops.call(farm_proc, body_addr)
    end
  end

  @spec move_absolute(FarmProc.t()) :: FarmProc.t()
  def move_absolute(%FarmProc{} = farm_proc) do
    pc       = FarmProc.get_pc_ptr(farm_proc)
    heap     = FarmProc.get_heap_by_page_index(farm_proc, pc.page)
    location = Csvm.DataResolver.resolve(heap, pc, :location)
    offset   = Csvm.DataResolver.resolve(heap, pc, :offset)
    speed    = Csvm.DataResolver.resolve(heap, pc, :speed)
    args     = %{ location: location, offset: offset, speed: speed }
    result   = Csvm.SysCallHandler.apply_sys_call_fun(farm_proc.sys_call_fun,
                                                      :move_absoloute,
                                                      args)
    new_farm_proc = handle_io_result(farm_proc, result)
    Ops.next_or_return(new_farm_proc)
  end

  # TODO(Connor) -  Fix this in the Heap/Slicer mods.
  def unquote(:"Elixir.Csvm.AST.Node.Nothing")(%FarmProc{} = farm_proc) do
    IO.puts("Sequence complete.")
    %FarmProc{farm_proc | status: :done}
  end

  defp handle_io_result(farm_proc, :ok), do: farm_proc

  defp handle_io_result(farm_proc, {:error, reason}),
    do: Ops.crash(farm_proc, reason)
end

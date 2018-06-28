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
    def next(%FarmProc{} = _farm_proc) do
      raise "PC = current.next"
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
    farm_proc
  end

  # TODO(Connor) -  Fix this in the Heap/Slicer mods.
  def unquote(:"Elixir.Csvm.AST.Node.Nothing")(%FarmProc{} = farm_proc) do
    IO.puts("Sequence complete.")
    %FarmProc{farm_proc | status: :done}
  end
end

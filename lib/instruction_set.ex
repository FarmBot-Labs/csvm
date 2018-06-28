defmodule Csvm.InstructionSet do
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer
  import Csvm.Instruction, only: [simple_io_instruction: 1]

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
      next_ptr = FarmProc.get_next_address(farm_proc, current_pc)
      FarmProc.set_pc_ptr(farm_proc, next_ptr)
    end

    @spec next_or_return(FarmProc.t()) :: FarmProc.t()
    def next_or_return(farm_proc) do
      pc_ptr = FarmProc.get_pc_ptr(farm_proc)
      addr = FarmProc.get_next_address(farm_proc, pc_ptr)

      if FarmProc.is_null_address?(addr) do
        Ops.return(farm_proc)
      else
        Ops.next(farm_proc)
      end
    end

    def crash(_farm_proc, reason) do
      raise("VM Crashed: " <> reason)
    end
  end

  simple_io_instruction(:move_absolute)
  simple_io_instruction(:move_relative)
  simple_io_instruction(:write_pin)
  simple_io_instruction(:read_pin)
  simple_io_instruction(:wait)
  simple_io_instruction(:send_message)
  simple_io_instruction(:find_home)

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = farm_proc) do
    body_addr = FarmProc.get_body_address(farm_proc, FarmProc.get_pc_ptr(farm_proc))

    if FarmProc.is_null_address?(body_addr) do
      IO.puts("This sequence has no body. Exiting.")
      Ops.return(farm_proc)
    else
      IO.puts("This sequence has a body. Entering: #{inspect(body_addr)}")
      Ops.call(farm_proc, body_addr)
    end
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

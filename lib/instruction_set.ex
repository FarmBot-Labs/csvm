defmodule Csvm.InstructionSet do
  alias Csvm.FarmProc
  # alias Csvm.FarmProc.Pointer
  alias Csvm.AST.Heap.Address, as: HeapAddress

  defmodule Ops do
    @spec call(FarmProc.t(), HeapAddress.t()) :: FarmProc.t()
    def call(%FarmProc{} = farm_proc, %HeapAddress{} = address) do
      # old_rs = FarmProc.get_return_stack(proc)
      # new_rs = [ FarmProc.get_pc_ptr(proc) | old_rs ]
      # %FarmProc{ proc | rs: new_rs, pc: address }

      farm_proc
      |> FarmProc.push_rs(FarmProc.get_pc_ptr(farm_proc))
      |> FarmProc.set_pc(address)
    end

    @spec return(FarmProc.t()) :: FarmProc.t()
    def return(%FarmProc{} = _farm_proc) do
      raise "PC = RS.pop()"
    end

    @spec next(FarmProc.t()) :: FarmProc.t()
    def next(%FarmProc{} = _farm_proc) do
      raise "PC = current.next"
    end
  end

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = farm_proc) do
    body_addr = FarmProc.maybe_get_body_address(farm_proc, FarmProc.get_pc_ptr(farm_proc))

    if body_addr do
      IO.puts("This sequence has a body. Entering.")
      Ops.call(farm_proc, body_addr)
    else
      IO.puts("This sequence has no body. Exiting.")
      Ops.return(farm_proc)
    end
  end
end

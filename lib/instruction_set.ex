defmodule Csvm.InstructionSet do
  alias Csvm.FarmProc
  defmodule Ops do
    @spec call(FarmProc.t(), Pointer.t()) :: FarmProc.t()
    def call(proc, address) do
      old_rs = FarmProc.get_return_stack(proc)
      new_rs = [ FarmProc.get_pc_ptr(proc) | old_rs ]
      %FarmProc{ proc | rs: new_rs, pc: address }
    end

    @spec return(FarmProc.t()) :: FarmProc.t()
    def return(proc) do
      raise "PC = RS.pop()"
    end

    @spec next(FarmProc.t()) :: FarmProc.t()
    def next(proc) do
      raise "PC = current.next"
    end
  end

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = fp) do
    body_addr = FarmProc.maybe_get_body_address(fp, FarmProc.get_pc_ptr(fp))
      if body_addr do
        IO.puts("This sequence has a body. Entering.")
        Ops.call(fp, body_addr)
      else
        IO.puts("This sequence has no body. Exiting.")
        Ops.return(fp)
      end
  end

  # so meta
  # def unquote(:"$handle_undefined_function")(fun, _args) do
  #   raise("Unknown kind: #{fun}")
  # end
end

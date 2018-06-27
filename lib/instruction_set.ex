defmodule Csvm.InstructionSet do
  alias Csvm.FarmProc

  @spec sequence(FarmProc.t) :: FarmProc.t
  def sequence(%FarmProc{} = fp) do
  end

  # so meta
  def unquote(:"$handle_undefined_function")(fun, _args) do
    raise("Unknown kind: #{fun}")
  end
end

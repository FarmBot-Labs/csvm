defmodule Csvm.Utils do
  alias Csvm.AST

  @spec ast(AST.kind(), AST.args(), AST.body()) :: AST.t()
  def ast(kind, args, body \\ []), do: AST.new(kind, args, body)

  @spec ptr(Address.value(), Address.value()) :: Pointer.t()
  def ptr(page, addr),
    do: Pointer.new(Address.new(page), Address.new(addr))

  @spec addr(Address.value()) :: Address.t()
  def addr(val), do: Address.new(val)
end

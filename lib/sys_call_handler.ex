defmodule Csvm.SysCallHandler do
  @type ast :: Csvm.AST.t()
  @type return_value :: :ok | {:error, String.t()}
  @type sys_call_fun :: (ast -> return_value)

  @spec apply_sys_call_fun(sys_call_fun, ast) :: return_value | no_return
  def apply_sys_call_fun(fun, ast) do
    case apply(fun, [ast]) do
      :ok -> :ok
      {:error, return} when is_binary(return) -> {:error, return}
      other -> raise("Bad return value: #{inspect(other)}")
    end
  end
end

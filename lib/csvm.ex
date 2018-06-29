defmodule Csvm do
  @moduledoc """
  Csvm structure. Handles many FarmProcs.
  """

  alias Csvm.{AST, FarmProc}

  defstruct sys_call_fun: nil,
            counter: 0,
            codez: %{},
            farm_procs: %{}

  @type t :: %Csvm{
          sys_call_fun: Csvm.SysCallHandler.sys_call_fun(),
          counter: integer,
          codez: %{integer => AST.t()},
          farm_procs: %{integer => FarmProc.t()}
        }

  @doc "initialize a new Csvm structure."
  @spec new(Csvm.SysCallHandler.sys_call_fun()) :: Csvm.t()
  def new(sys_call_fun) do
    struct(Csvm, sys_call_fun: sys_call_fun)
  end

  @spec tick(Csvm.t()) :: Csvm.t()
  def tick(%Csvm{} = fixme) do
    fixme
  end

  @doc "Increment the counter."
  @spec incr_count(Csvm.t()) :: Csvm.t()
  def incr_count(%Csvm{counter: counter} = csvm) do
    %Csvm{csvm | counter: counter + 1}
  end

  @doc "Sets code from ast."
  @spec set_code(Csvm.t(), integer, AST.t()) :: Csvm.t()
  def set_code(%Csvm{codez: code} = csvm, location, %AST{} = ast)
      when is_integer(location) do
    %Csvm{csvm | codez: Map.put(code, location, ast)}
  end
end

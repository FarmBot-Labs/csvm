defmodule Csvm do
  @moduledoc """
  Csvm structure. Handles many FarmProcs.
  """

  alias Csvm.{AST, FarmProc}

  defstruct interaction_handler: nil,
            private: nil,
            counter: 0,
            codez: %{},
            farm_procs: %{}

  @typedoc """
  Data to be passed straight through to the `interaction_handler`
  function calls.
  """
  @opaque private_data :: map | nil

  @type t :: %Csvm{
          interaction_handler: module,
          private: private_data,
          counter: integer,
          codez: %{integer => AST.t()},
          farm_procs: %{integer => FarmProc.t()}
        }

  @doc "initialize a new Csvm structure."
  @spec new(module) :: Csvm.t()
  def new(interaction_handler) do
    # TODO(Conoor) Check the interaction_handler handler's behaviour.
    struct(Csvm, interaction_handler: interaction_handler)
  end

  @doc "Assign private data to the vm."
  @spec assign(Csvm.t(), private_data) :: Csvm.t()
  def assign(%Csvm{} = csvm, %{} = private) do
    %Csvm{csvm | private: private}
  end

  @spec tick(Csvm.t()) :: Csvm.t()
  def tick(%Csvm{}) do
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

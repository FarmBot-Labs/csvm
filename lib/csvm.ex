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
  def new(interaction_handler) do
    # TODO(Conoor) Check the interaction_handler handler's behaviour.
    struct(Csvm, interaction_handler: interaction_handler)
  end

  @doc "Assign private data to the vm."
  def asign(csvm, %{} = private) do
    %{csvm | private: private}
  end

  def tick(csvm) do
  end

  @doc "Increment the counter."
  def incr_count(csvm) do
    %{csvm | counter: csvm.counter + 1}
  end

  @doc "Sets code from ast."
  def set_code(csvm, location, %AST{} = ast) do
    %{csvm | code: Map.put(csvm.code, location, ast)}
  end
end

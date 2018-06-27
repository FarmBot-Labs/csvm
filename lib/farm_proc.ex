defmodule Csvm.FarmProc do
  alias Csvm.FarmProc
  alias Csvm.AST.Heap

  defstruct interaction_handler: nil,
            pc: 0,
            par: 0,
            rs: [],
            heap: %{}

  @typedoc ~s(Program counter)
  @type pc :: integer

  @typedoc ~s(Page address register)
  @type par :: integer

  @type t :: %FarmProc{
          interaction_handler: module,
          pc: pc,
          par: par,
          rs: [{pc, par}],
          heap: %{par => Heap.t()}
        }

  def new(interaction_handler, heap) do
    struct(
      FarmProc,
      interaction_handler: interaction_handler,
      heap: %{0 => heap}
    )
  end

  def tick(farm_proc) do
  end
end

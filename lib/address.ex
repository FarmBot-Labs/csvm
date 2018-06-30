defmodule Address do
  @moduledoc "Address on the heap."

  defstruct [:value]

  @type value :: integer

  @type t :: %__MODULE__{value: value}

  @typedoc "Null address."
  @type null :: %__MODULE__{value: 0}

  @doc "New heap address."
  @spec new(integer) :: t()
  def new(num) when is_integer(num), do: %__MODULE__{value: num}

  @spec null :: null()
  def null, do: %__MODULE__{value: 0}

  @doc "Increment an address."
  @spec inc(t) :: t()
  def inc(%__MODULE__{value: num}), do: %__MODULE__{value: num + 1}

  @doc "Decrement an address."
  @spec dec(t) :: t()
  def dec(%__MODULE__{value: num}), do: %__MODULE__{value: num - 1}

  defimpl Inspect, for: __MODULE__ do
    def inspect(%Address{value: val}, _), do: "#Address<#{val}>"
  end
end

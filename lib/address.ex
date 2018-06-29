defmodule Address do
  @moduledoc "Address on the heap."

  defstruct [:value]

  @type t :: %__MODULE__{value: integer}

  @typedoc "Null address."
  @type null :: %__MODULE__{value: 0}

  @doc "New heap address."
  @spec new(integer) :: t()
  def new(num) when is_integer(num) do
    %__MODULE__{value: num}
  end

  @spec null :: null()
  def null do
    %__MODULE__{value: 0}
  end

  @doc "Increment an address."
  @spec inc(t) :: t
  def inc(%__MODULE__{value: num}) do
    %__MODULE__{value: num + 1}
  end

  @doc "Decrement an address."
  @spec dec(t) :: t
  def dec(%__MODULE__{value: num}) do
    %__MODULE__{value: num - 1}
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(%{value: val}, _), do: "HeapAddress(#{val})"
  end
end

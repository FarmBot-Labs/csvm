defmodule Csvm.CircularList do
  defstruct current_index: 0, items: %{}, autoinc: 0

  def new() do
    %CircularList{}
  end

  def current(this) do
    this.items[this.current_index]
  end

  def rotate(this) do
    current = this.current_index
    keys = Enum.sort(Map.keys(this.items))
    # Grab first where index > this.current_index, or keys.first
    next_key = Enum.find(keys, List.first(keys), fn key -> key > current end)
    %CircularList{this | current_index: next_key}
  end

  def push(this, item) do
    # Bump autoinc
    next_autoinc = this.autoinc + 1
    next_items = Map.put(this.items, next_autoinc, item)
    # Add the item
    %CircularList{this | autoinc: next_autoinc, items: next_items}
  end

  def remove() do
    raise "Not impl"
  end
end

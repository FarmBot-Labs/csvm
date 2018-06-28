defmodule Csvm.DataResolver do
# MOVE_REL WILL NEED:
# * {x, y, z}

# LOCATION WILL DEAL WITH:
# * :tool       (MUST be handled by host)
# * :point      (can be handled by host)
#   { point_id: 123}
# * :coordinate (MUST be handled by host)
#   { x, y, z}
# * :identifier (cant be dealt with by host)
#   it depends
  @spec resolve(Heap.t(), Pointer.t(), atom) :: any | no_return
  def resolve(heap, ptr, kind) do
    cell = get_cell(heap, ptr)
    data = get_attr(cell, kind)
    heap[data]
  end

  defp get_cell(heap, ptr) do
    heap[ptr.heap_address] || raise "Bad heap address"
  end

  defp get_attr(cell, name) do
    data = cell[name] || cell[:"__#{name}"]
    if data do
      data
    else
      IO.inspect(cell)
      raise "Bad attr: #{name}"
    end
  end
end

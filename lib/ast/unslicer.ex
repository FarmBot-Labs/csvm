defmodule Csvm.AST.Unslicer do
  alias Csvm.AST
  alias Csvm.AST.Heap
  alias Heap.Address, as: HeapAddress

  @spec run(Heap.t, HeapAddress.t) :: AST.t
  def run(heap, addr) do
    heap
    |> unslice(addr)
    |> Csvm.AST.parse()
  end

  def unslice(heap, addr) do
    here_cell = heap[addr] || raise "whoops"
    results = Enum.reduce(here_cell, %{"args" => %{}}, fn({key, value}, acc) ->
      if is_link?(key) do
        cond do
          key == Heap.body() ->
            if heap[value][Heap.kind()] == :nothing do
              acc
            else
              next_addr = value
              n = heap[next_addr]
              body = reduce_body(n, next_addr, heap, [])
              Map.put(acc, "body", body)
            end
          key == Heap.kind() -> Map.put(acc, "kind", to_string(value))
          key == Heap.parent() -> acc
          key == Heap.next() -> acc
          key == Heap.null() ->
            #TODO(Connor) - Remove this in AUG 18
            raise("what is this??")
          true ->
            key = String.replace(to_string(key), "__", "")
            args = Map.put(acc["args"], key, unslice(heap, value))
            %{acc | "args" => args}
        end
      else
        %{acc | "args" => Map.put(acc["args"], to_string(key), value)}
      end
    end)
  end

  def is_link?(key) do
    String.starts_with?(to_string(key), Heap.link())
  end

  def reduce_body(%{__kind: AST.Node.Nothing}, next_addr, heap, acc), do: acc
  def reduce_body(%{} = cell, %HeapAddress{} = next_addr, heap, acc) do
    item = unslice(heap, next_addr)
    new_acc = acc ++ [item]
    next_addr = cell[Heap.next()]
    next_cell = heap[next_addr]
    reduce_body(next_cell, next_addr, heap, new_acc)
  end
end

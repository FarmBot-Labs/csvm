defmodule Csvm.AST.HeapTest do
  use ExUnit.Case
  alias Csvm.AST
  alias AST.Heap

  describe "Address" do
    test "inspect gives nice stuff" do
      assert inspect(Address.new(100)) == "HeapAddress(100)"
    end

    test "increments an address" do
      base = Address.new(123)
      assert Address.inc(base) == Address.new(124)
    end

    test "decrements an address" do
      base = Address.new(123)
      assert Address.dec(base) == Address.new(122)
    end
  end

  test "initializes a new heap" do
    heap = Heap.new()
    assert is_null?(heap.here)
  end

  test "alots one kind on the heap" do
    heap = Heap.new()
    aloted = Heap.alot(heap, "abc")
    assert aloted.here == Address.new(1)
    assert match?(%{:__kind => "abc"}, aloted.entries[Address.new(1)])
  end

  test "Heap access with address" do
    heap =
      Heap.new()
      |> Heap.alot("abc")
      |> Heap.alot("def")
      |> Heap.alot("ghi")

    assert is_null?(heap.entries[Address.new(0)])
    assert match?(%{:__kind => "abc"}, heap.entries[Address.new(1)])
    assert match?(%{:__kind => "def"}, heap.entries[Address.new(2)])
    assert match?(%{:__kind => "ghi"}, heap.entries[Address.new(3)])
  end

  test "puts a key value pair on an existing aloted slot" do
    heap =
      Heap.new()
      |> Heap.alot("abc")
      |> Heap.put("key", "value")

    assert match?(%{:__kind => "abc", key: "value"}, heap.entries[Address.new(1)])
  end

  test "Puts key/value pairs at arbitrary addresses" do
    heap =
      Heap.new()
      |> Heap.alot("abc")
      |> Heap.alot("def")
      |> Heap.alot("ghi")

    mutated = Heap.put(heap, Address.new(2), "abc_key", "value")
    assert match?(%{:__kind => "def", abc_key: "value"}, mutated.entries[Address.new(2)])
  end

  test "Can't update on bad a address" do
    heap =
      Heap.new()
      |> Heap.alot("abc")
      |> Heap.alot("def")
      |> Heap.alot("ghi")

    assert_raise RuntimeError, fn ->
      Heap.put(heap, Address.new(200), "abc_key", "value")
    end
  end

  defp is_null?(%Address{value: 0}), do: true
  defp is_null?(%Address{value: _}), do: false

  defp is_null?(%{
         __body: %Address{value: 0},
         __kind: :nothing,
         __next: %Address{value: 0},
         __parent: %Address{value: 0}
       }),
       do: true

  defp is_null?(_), do: false
end

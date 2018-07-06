defmodule Csvm.Resolver do
  alias Csvm.{FarmProc, AST}

  @nodes_with_declerations [:sequence]

  @spec resolve(FarmProc.t(), Pointer.t(), String.t()) :: AST.t()
  def resolve(%FarmProc{} = farm_proc, %Pointer{} = pointer, label) do
    # step1 keep climbing (recursivly) __parent until kind in @nodes_with_declerations
    # step2 execute rule for resolution per node
    # step2.5 if no data, explode
    # step3 unslice at address
    # step4 profit??
    search_tree(farm_proc, pointer, label)
  end

  def search_tree(farm_proc, %Pointer{} = pointer, label) do
    if FarmProc.is_null_address?(pointer) do
      raise "unbound identifier: #{label} from pc: #{inspect(pointer)}"
    end

    kind = FarmProc.get_kind(farm_proc, pointer)

    if kind in @nodes_with_declerations do
      result = do_resolve(kind, farm_proc, pointer, label)
      %Address{} = zero_page = FarmProc.get_zero_page(farm_proc)
      %Pointer{} = new_pointer = Pointer.new(zero_page, FarmProc.get_parent(farm_proc, pointer))

      if is_nil(result) do
        search_tree(farm_proc, new_pointer, label)
      else
        result
      end
    else
      %Address{} = zero_page = FarmProc.get_zero_page(farm_proc)
      %Pointer{} = new_pointer = Pointer.new(zero_page, FarmProc.get_parent(farm_proc, pointer))
      search_tree(farm_proc, new_pointer, label)
    end
  end

  def do_resolve(:sequence, farm_proc, pointer, label) do
    locals_ptr = FarmProc.get_cell_attr_as_pointer(farm_proc, pointer, :__locals)
    ast = AST.unslice(farm_proc.heap[locals_ptr.page_address], locals_ptr.heap_address)

    Enum.find_value(ast.body, fn %{args: %{label: sub_label, data_value: val}} ->
      if sub_label == label do
        val
      end
    end)
  end
end

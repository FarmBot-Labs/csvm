defmodule Csvm.FarmProc do
  alias Csvm.FarmProc
  alias Csvm.AST.Heap

  @instruction_set Csvm.InstructionSet
  @max_reduction_count 1000

  defstruct sys_call_fun: nil,
            zero_page: nil,
            reduction_count: 0,
            pc: nil,
            rs: [],
            status: :ok,
            heap: %{}

  @typedoc "Program counter"
  @type heap_address :: Address.t()

  @typedoc "Page address register"
  @type page :: integer

  @type status_enum :: :ok | :crashed

  defmodule Pointer do
    defstruct [:heap_address, :page]
    @type t :: %__MODULE__{heap_address: FarmProc.heap_address(), page: FarmProc.page()}
    @spec new(FarmProc.page(), FarmProc.heap_address()) :: t
    def new(page, %Address{} = ha) when is_integer(page) do
      %Pointer{
        heap_address: ha,
        page: page
      }
    end

    @spec null(FarmProc.t()) :: t()
    def null(%FarmProc{} = farm_proc) do
      %Pointer{
        heap_address: Address.new(0),
        page: FarmProc.get_zero_page_num(farm_proc)
      }
    end
  end

  @type t :: %FarmProc{
          sys_call_fun: Csvm.SysCallHandler.sys_call_fun(),
          status: status_enum(),
          zero_page: page,
          pc: Pointer.t(),
          rs: [Pointer.t()],
          reduction_count: pos_integer(),
          heap: %{page => Heap.t()}
        }

  @spec new(Csvm.SysCallHandler.sys_call_fun(), page, Heap.t()) :: FarmProc.t()
  def new(sys_call_fun, page_num, %Heap{} = heap)
      when is_function(sys_call_fun)
      when is_integer(page_num) do
    struct(
      FarmProc,
      status: :ok,
      zero_page: page_num,
      pc: Pointer.new(page_num, Address.new(1)),
      sys_call_fun: sys_call_fun,
      heap: %{page_num => heap}
    )
  end

  @spec new_page(FarmProc.t(), page, Heap.t()) :: FarmProc.t()
  def new_page(%FarmProc{} = farm_proc, page_num, heap_contents) do
    new_heap = Map.put(farm_proc.heap, page_num, heap_contents)
    %FarmProc{farm_proc | heap: new_heap}
  end

  @spec get_zero_page_num(FarmProc.t()) :: page
  def get_zero_page_num(%FarmProc{} = farm_proc) do
    farm_proc.zero_page
  end

  @spec has_page?(FarmProc.t(), page) :: boolean()
  def has_page?(%FarmProc{} = farm_proc, page) do
    Map.has_key?(farm_proc.heap, page)
  end

  @spec step(FarmProc.t()) :: FarmProc.t() | no_return
  def step(%FarmProc{status: :crashed} = _farm_proc) do
    raise("Tried to step with crashed process!")
  end

  def step(%FarmProc{reduction_count: c}) when c >= @max_reduction_count do
    raise("Too many reductions!")
  end

  def step(%FarmProc{} = farm_proc) do
    pc_ptr = get_pc_ptr(farm_proc)
    kind = get_kind(farm_proc, pc_ptr)

    unless Code.ensure_loaded?(@instruction_set) and function_exported?(@instruction_set, kind, 1) do
      raise("No implementation for: #{kind}")
    end

    farm_proc = %FarmProc{farm_proc | reduction_count: farm_proc.reduction_count + 1}
    # IO.puts "executing: [#{pc_ptr.page}, #{inspect pc_ptr.heap_address}] #{kind}"
    apply(@instruction_set, kind, [farm_proc])
  end

  @spec get_pc_ptr(FarmProc.t()) :: Pointer.t()
  def get_pc_ptr(%FarmProc{pc: pc}), do: pc

  @spec set_pc_ptr(FarmProc.t(), Pointer.t()) :: FarmProc.t()
  def set_pc_ptr(%FarmProc{} = farm_proc, %Pointer{} = pc) do
    %FarmProc{farm_proc | pc: pc}
  end

  @spec get_heap_by_page_index(FarmProc.t(), page) :: Heap.t() | no_return
  def get_heap_by_page_index(%FarmProc{heap: heap}, page) do
    heap[page] || raise("no page")
  end

  @spec get_return_stack(FarmProc.t()) :: [Pointer.t()]
  def get_return_stack(%FarmProc{rs: rs}), do: rs

  @spec get_kind(FarmProc.t(), Pointer.t()) :: atom
  def get_kind(%FarmProc{} = farm_proc, %Pointer{} = ptr) do
    get_cell_by_address(farm_proc, ptr)[Heap.kind()]
  end

  @spec get_status(FarmProc.t()) :: status_enum()
  def get_status(%FarmProc{status: status}), do: status

  @spec set_status(FarmProc.t(), status_enum()) :: FarmProc.t()
  def set_status(%FarmProc{} = farm_proc, status) do
    %FarmProc{farm_proc | status: status}
  end

  # TODO(Rick): Use `cell` type, not `map`. - 28 JUN 18
  # @spec get_pc_cell(FarmProc.t()) :: Heap.cell()
  # def get_pc_cell(%FarmProc{} = farm_proc) do
  #   get_cell_by_address(farm_proc, get_pc_ptr(farm_proc))
  # end

  @spec get_body_address(FarmProc.t(), Pointer.t()) :: Pointer.t()
  def get_body_address(%FarmProc{} = farm_proc, %Pointer{} = here_address) do
    get_cell_attr_as_pointer(farm_proc, here_address, Heap.body())
  end

  @spec get_next_address(FarmProc.t(), Pointer.t()) :: Pointer.t()
  def get_next_address(%FarmProc{} = farm_proc, %Pointer{} = here_address) do
    get_cell_attr_as_pointer(farm_proc, here_address, Heap.next())
  end

  @spec get_cell_attr(FarmProc.t(), Pointer.t(), atom) :: any()
  def get_cell_attr(%FarmProc{} = farm_proc, %Pointer{} = location, field) do
    cell = get_cell_by_address(farm_proc, location)
    cell[field] || raise("#{inspect(cell)} has no field called: #{field}")
  end

  def get_cell_attr_as_pointer(%FarmProc{} = farm_proc, %Pointer{} = location, field) do
    %Address{} = data = get_cell_attr(farm_proc, location, field)
    Pointer.new(location.page, data)
  end

  @spec push_rs(FarmProc.t(), Pointer.t()) :: FarmProc.t()
  def push_rs(%FarmProc{} = farm_proc, %Pointer{} = ptr) do
    new_rs = [ptr | FarmProc.get_return_stack(farm_proc)]
    %FarmProc{farm_proc | rs: new_rs}
  end

  @spec pop_rs(FarmProc.t()) :: {Pointer.t(), FarmProc.t()}
  def pop_rs(%FarmProc{rs: rs} = farm_proc) do
    case rs do
      [hd | new_rs] -> {hd, %FarmProc{farm_proc | rs: new_rs}}
      [] -> {Pointer.null(farm_proc), farm_proc}
    end
  end

  @spec is_null_address?(Address.t() | Pointer.t()) :: boolean()
  def is_null_address?(%Address{value: 0}), do: true
  def is_null_address?(%Address{}), do: false

  def is_null_address?(%Pointer{heap_address: %Address{value: 0}}),
    do: true

  def is_null_address?(%Pointer{}), do: false

  @spec get_cell_by_address(FarmProc.t(), Pointer.t()) :: map | no_return
  def get_cell_by_address(
        %FarmProc{} = farm_proc,
        %Pointer{page: page, heap_address: %Address{} = ha}
      ) do
    get_heap_by_page_index(farm_proc, page)[ha] || raise("bad address")
  end
end

defmodule Csvm.FarmProc do
  alias Csvm.FarmProc
  alias Csvm.AST.Heap
  alias Csvm.AST.Heap.Address, as: HeapAddress

  @instruction_set Csvm.InstructionSet

  defstruct sys_call_fun: nil,
            pc: nil,
            rs: [],
            status: :ok,
            heap: %{}

  @typedoc "Program counter"
  @type heap_address :: HeapAddress.t()

  @typedoc "Page address register"
  @type page :: integer

  @type status_enum :: :ok | :done

  defmodule Pointer do
    defstruct [:heap_address, :page]
    @type t :: %__MODULE__{heap_address: FarmProc.heap_address(), page: FarmProc.page()}
    @spec new(FarmProc.page(), FarmProc.heap_address()) :: t
    def new(page, %HeapAddress{} = ha) when is_integer(page) do
      %Pointer{
        heap_address: ha,
        page: page
      }
    end

    @spec null :: t
    def null do
      %Pointer{
        heap_address: HeapAddress.new(0),
        page: 0
      }
    end
  end

  @type t :: %FarmProc{
          sys_call_fun: Csvm.SysCallHandler.sys_call_fun(),
          status: status_enum(),
          pc: Pointer.t(),
          rs: [Pointer.t()],
          heap: %{page => Heap.t()}
        }

  @spec new(Csvm.SysCallHandler.sys_call_fun(), Heap.t()) :: FarmProc.t()
  def new(sys_call_fun, heap) do
    struct(
      FarmProc,
      status: :ok,
      pc: Pointer.new(0, HeapAddress.new(1)),
      sys_call_fun: sys_call_fun,
      heap: %{0 => heap}
    )
  end

  @spec step(FarmProc.t()) :: FarmProc.t() | no_return
  def step(%FarmProc{} = farm_proc) do
    pc_ptr = get_pc_ptr(farm_proc)
    kind = get_kind(farm_proc, pc_ptr)

    unless Code.ensure_loaded?(@instruction_set) and function_exported?(@instruction_set, kind, 1) do
      raise("No implementation for: #{kind}")
    end

    apply(@instruction_set, kind, [farm_proc])
  end

  @spec get_pc_ptr(FarmProc.t()) :: Pointer.t()
  def get_pc_ptr(%FarmProc{pc: pc}), do: pc

  @spec set_pc_ptr(FarmProc.t(), Pointer.t()) :: FarmProc.t()
  def set_pc_ptr(%FarmProc{} = farm_proc, %Pointer{} = pc),
    do: %FarmProc{farm_proc | pc: pc}

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

  # TODO(Rick): Use `cell` type, not `map`. - 28 JUN 18
  @spec get_pc_cell(FarmProc.t()) :: map | no_return
  def get_pc_cell(%FarmProc{} = farm_proc) do
    get_cell_by_address(farm_proc, get_pc_ptr(farm_proc))
  end

  @spec get_body_address(FarmProc.t(), Pointer.t()) :: Pointer.t() | no_return
  def get_body_address(%FarmProc{} = farm_proc, %Pointer{} = here_address) do
    cell = get_cell_by_address(farm_proc, here_address)
    body_heap_address = cell[Heap.body()] || raise("#{inspect(cell)} has no body pointer")
    Pointer.new(here_address.page, body_heap_address)
  end

  @spec get_next_address(FarmProc.t(), Pointer.t()) :: Pointer.t() | no_return
  def get_next_address(%FarmProc{} = farm_proc, %Pointer{} = here_address) do
    cell = get_cell_by_address(farm_proc, here_address)
    next_heap_address = cell[Heap.next()] || raise("#{inspect(cell)} has no `next` pointer")
    Pointer.new(here_address.page, next_heap_address)
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
      [] -> {Pointer.null(), farm_proc}
    end
  end

  @spec is_null_address?(HeapAddress.t() | Pointer.t()) :: boolean()
  def is_null_address?(%HeapAddress{value: 0}), do: true
  def is_null_address?(%HeapAddress{}), do: false

  def is_null_address?(%Pointer{heap_address: %HeapAddress{value: 0}}),
    do: true

  def is_null_address?(%Pointer{}), do: false

  @spec get_cell_by_address(FarmProc.t(), Pointer.t()) :: map | no_return
  def get_cell_by_address(
        %FarmProc{} = farm_proc,
        %Pointer{page: page, heap_address: %HeapAddress{} = ha}
      ) do
    get_heap_by_page_index(farm_proc, page)[ha] || raise("bad address")
  end
end

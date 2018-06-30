defmodule Csvm.FarmProc do
  alias Csvm.{
    AST,
    FarmProc,
    SysCallHandler,
    InstructionSet
  }
  alias AST.Heap

  @instruction_set InstructionSet
  @max_reduction_count 1000

  defstruct sys_call_fun: nil,
            zero_page: nil,
            reduction_count: 0,
            pc: nil,
            rs: [],
            io_latch: nil,
            io_result: nil,
            crash_reason: nil,
            status: :ok,
            heap: %{}

  @typedoc "Program counter"
  @type heap_address :: Address.t()

  @typedoc "Page address register"
  @type page :: Address.t()

  @type status_enum :: :ok | :crashed | :waiting

  @type t :: %FarmProc{
          sys_call_fun: SysCallHandler.sys_call_fun(),
          status: status_enum(),
          zero_page: page,
          pc: Pointer.t(),
          rs: [Pointer.t()],
          reduction_count: pos_integer(),
          heap: %{page => Heap.t()}
        }

  @spec new(Csvm.SysCallHandler.sys_call_fun(), page, Heap.t()) :: FarmProc.t()
  def new(sys_call_fun, %Address{} = page, %Heap{} = heap)
      when is_function(sys_call_fun)
       do
    struct(
      FarmProc,
      status: :ok,
      zero_page: page,
      pc: Pointer.new(page, Address.new(1)),
      sys_call_fun: sys_call_fun,
      heap: %{page => heap}
    )
  end

  @spec new_page(FarmProc.t(), page, Heap.t()) :: FarmProc.t()
  def new_page(%FarmProc{} = farm_proc, %Address{} = page_num, %Heap{} = heap_contents) do
    new_heap = Map.put(farm_proc.heap, page_num, heap_contents)
    %FarmProc{farm_proc | heap: new_heap}
  end

  @spec get_zero_page_num(FarmProc.t()) :: page
  def get_zero_page_num(%FarmProc{} = farm_proc) do
    farm_proc.zero_page
  end

  @spec has_page?(FarmProc.t(), page) :: boolean()
  def has_page?(%FarmProc{} = farm_proc, %Address{} = page) do
    Map.has_key?(farm_proc.heap, page)
  end

  @spec step(FarmProc.t()) :: FarmProc.t() | no_return
  def step(%FarmProc{status: :crashed} = _farm_proc) do
    raise("Tried to step with crashed process!")
  end

  def step(%FarmProc{reduction_count: c}) when c >= @max_reduction_count do
    raise("Too many reductions!")
  end

  def step(%FarmProc{status: :waiting} = farm_proc) do
    case Csvm.SysCallHandler.get_status(farm_proc.io_latch) do
      :ok ->
        farm_proc

      :complete ->
        FarmProc.set_status(farm_proc, :ok)
        |> FarmProc.set_io_latch_result(Csvm.SysCallHandler.get_results(farm_proc.io_latch))
        |> FarmProc.remove_io_latch()
        |> FarmProc.step()
    end
  end

  def step(%FarmProc{} = farm_proc) do
    pc_ptr = get_pc_ptr(farm_proc)
    kind = get_kind(farm_proc, pc_ptr)

    unless Code.ensure_loaded?(@instruction_set) and function_exported?(@instruction_set, kind, 1) do
      raise("No implementation for: #{kind}")
    end

    farm_proc = %FarmProc{farm_proc | reduction_count: farm_proc.reduction_count + 1}
    # IO.puts "executing: [#{pc_ptr.page_address}, #{inspect pc_ptr.heap_address}] #{kind}"
    apply(@instruction_set, kind, [farm_proc])
  end

  @spec get_pc_ptr(FarmProc.t()) :: Pointer.t()
  def get_pc_ptr(%FarmProc{pc: pc}), do: pc

  @spec set_pc_ptr(FarmProc.t(), Pointer.t()) :: FarmProc.t()
  def set_pc_ptr(%FarmProc{} = farm_proc, %Pointer{} = pc) do
    %FarmProc{farm_proc | pc: pc}
  end

  def set_io_latch(%FarmProc{} = farm_proc, pid) when is_pid(pid) do
    %FarmProc{farm_proc | io_latch: pid}
  end

  def set_io_latch_result(%FarmProc{} = farm_proc, result) do
    %FarmProc{farm_proc | io_result: result}
  end

  def clear_io_result(%FarmProc{} = farm_proc) do
    %FarmProc{farm_proc | io_result: nil}
  end

  def remove_io_latch(%FarmProc{} = farm_proc) do
    %FarmProc{farm_proc | io_latch: nil}
  end

  @spec get_heap_by_page_index(FarmProc.t(), page) :: Heap.t() | no_return
  def get_heap_by_page_index(%FarmProc{heap: heap}, %Address{} = page) do
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

  @spec get_cell_attr_as_pointer(FarmProc.t(), Pointer.t(), atom) :: Pointer.t()
  def get_cell_attr_as_pointer(%FarmProc{} = farm_proc, %Pointer{} = location, field) do
    %Address{} = data = get_cell_attr(farm_proc, location, field)
    Pointer.new(location.page_address, data)
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
      [] -> {Pointer.null(FarmProc.get_zero_page_num(farm_proc)), farm_proc}
    end
  end

  @spec get_crash_reason(FarmProc.t()) :: String.t() | nil
  def get_crash_reason(%FarmProc{} = crashed) do
    crashed.crash_reason
  end

  @spec set_crash_reason(FarmProc.t(), String.t()) :: FarmProc.t()
  def set_crash_reason(%FarmProc{} = crashed, reason) when is_binary(reason) do
    %FarmProc{crashed | crash_reason: reason}
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
        %Pointer{page_address: page, heap_address: %Address{} = ha}
      ) do
    get_heap_by_page_index(farm_proc, page)[ha] || raise("bad address")
  end
end

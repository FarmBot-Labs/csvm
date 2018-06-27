defmodule Csvm.FarmProc do
  alias Csvm.FarmProc
  alias Csvm.AST.Heap
  alias Csvm.AST.Heap.Address, as: HeapAddress

  @instruction_set Csvm.InstructionSet

  defstruct sys_call_fun: nil,
            pc: 0,
            rs: [],
            heap: %{}

  @typedoc "Program counter"
  @type pc :: HeapAddress.t()

  @typedoc "Page address register"
  @type par :: integer

  defmodule Pointer do
    defstruct [:pc, :par]
    @type t :: %__MODULE__{pc: FarmProc.pc(), par: FarmProc.par()}
    @spec new(FarmProc.par(), FarmProc.pc()) :: t
    def new(par, %HeapAddress{} = pc) when is_integer(par) do
      %Pointer{
        pc: pc,
        par: par
      }
    end
  end

  @type t :: %FarmProc{
          sys_call_fun: Csvm.SysCallHandler.sys_call_fun(),
          pc: Pointer.t(),
          rs: [Pointer.t()],
          heap: %{par => Heap.t()}
        }

  @spec new(Csvm.SysCallHandler.sys_call_fun(), Heap.t()) :: FarmProc.t()
  def new(sys_call_fun, heap) do
    struct(
      FarmProc,
      pc: Pointer.new(0, HeapAddress.new(1)),
      sys_call_fun: sys_call_fun,
      heap: %{0 => heap}
    )
  end

  @spec step(FarmProc.t()) :: FarmProc.t() | no_return
  def step(%FarmProc{} = farm_proc) do
    pc_ptr = get_pc_ptr(farm_proc)
    kind = get_kind(farm_proc, pc_ptr)

    unless function_exported?(@instruction_set, kind, 1) do
      raise("No implementation for: #{kind}")
    end

    apply(@instruction_set, kind, [farm_proc])
  end

  @spec get_pc_ptr(FarmProc.t()) :: Pointer.t()
  def get_pc_ptr(%FarmProc{pc: pc}) do
    pc
  end

  @spec get_heap_by_page_addr(FarmProc.t(), par) :: Heap.t() | no_return
  def get_heap_by_page_addr(%FarmProc{heap: heap}, index) do
    heap[index] || raise("no page")
  end

  @spec get_return_stack(FarmProc.t()) :: [Pointer.t()]
  def get_return_stack(%FarmProc{rs: rs}), do: rs

  @spec get_kind(FarmProc.t(), Pointer.t()) :: atom
  def get_kind(%FarmProc{} = farm_proc, %Pointer{pc: pc, par: par}) do
    get_cell_by_address(farm_proc, par, pc)[Heap.kind()]
  end

  # @spec get_pc_cell(FarmProc.t()) :: map | no_return
  # def get_pc_cell(%FarmProc{} = farm_proc) do
  #   %Point{pc: pc, par: par} = get_pc_ptr(farm_proc)
  #   get_cell_by_address(farm_proc, par, pc)
  # end

  @spec maybe_get_body_address(FarmProc.t(), Pointer.t()) :: Pointer.t() | nil
  def maybe_get_body_address(fp, here_address) do
    cell = get_heap_by_page_addr(fp, here_address.par)[here_address.pc]
    if cell do
      cell[Heap.body]
    end
  end

  # Private
  @spec get_cell_by_address(FarmProc.t(), par, pc) :: map | no_return
  defp get_cell_by_address(%FarmProc{} = farm_proc, par, pc) when is_integer(par) do
    get_heap_by_page_addr(farm_proc, par)[pc] || raise("bad address")
  end
end

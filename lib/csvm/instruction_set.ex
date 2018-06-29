defmodule Csvm.InstructionSet do
  alias Csvm.AST
  alias Csvm.FarmProc
  alias Csvm.FarmProc.Pointer
  import Csvm.Instruction, only: [simple_io_instruction: 1]
  import Csvm.SysCallHandler, only: [apply_sys_call_fun: 2]

  defmodule Ops do
    @spec call(FarmProc.t(), Pointer.t()) :: FarmProc.t()
    def call(%FarmProc{} = farm_proc, %Pointer{} = address) do
      current_pc = FarmProc.get_pc_ptr(farm_proc)
      next_ptr = FarmProc.get_next_address(farm_proc, current_pc)

      farm_proc
      |> FarmProc.push_rs(next_ptr)
      |> FarmProc.set_pc_ptr(address)
    end

    @spec return(FarmProc.t()) :: FarmProc.t()
    def return(%FarmProc{} = farm_proc) do
      {value, farm_proc} = FarmProc.pop_rs(farm_proc)
      FarmProc.set_pc_ptr(farm_proc, value)
    end

    @spec next(FarmProc.t()) :: FarmProc.t()
    def next(%FarmProc{} = farm_proc) do
      current_pc = FarmProc.get_pc_ptr(farm_proc)
      next_ptr = FarmProc.get_next_address(farm_proc, current_pc)
      FarmProc.set_pc_ptr(farm_proc, next_ptr)
    end

    @spec next_or_return(FarmProc.t()) :: FarmProc.t()
    def next_or_return(farm_proc) do
      pc_ptr = FarmProc.get_pc_ptr(farm_proc)
      addr = FarmProc.get_next_address(farm_proc, pc_ptr)

      if FarmProc.is_null_address?(addr) do
        Ops.return(farm_proc)
      else
        Ops.next(farm_proc)
      end
    end

    @spec crash(FarmProc.t(), String.t()) :: FarmProc.t()
    def crash(farm_proc, reason) do
      crash_address = FarmProc.get_pc_ptr(farm_proc)
      # Push PC -> RS
      farm_proc
      |> FarmProc.push_rs(crash_address)
      # set PC to 0,0
      |> FarmProc.set_pc_ptr(Pointer.null(farm_proc))
      # Set status to crashed, return the farmproc
      |> FarmProc.set_status(:crashed)
      |> FarmProc.set_crash_reason(reason)
    end
  end

  simple_io_instruction(:move_absolute)
  simple_io_instruction(:move_relative)
  simple_io_instruction(:write_pin)
  simple_io_instruction(:read_pin)
  simple_io_instruction(:wait)
  simple_io_instruction(:send_message)
  simple_io_instruction(:find_home)

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = farm_proc) do
    body_addr = FarmProc.get_body_address(farm_proc, FarmProc.get_pc_ptr(farm_proc))

    if FarmProc.is_null_address?(body_addr) do
      Ops.return(farm_proc)
    else
      Ops.call(farm_proc, body_addr)
    end
  end

  @spec _if(FarmProc.t()) :: FarmProc.t()
  def _if(%FarmProc{} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page)
    data = Csvm.AST.Unslicer.run(heap, pc.heap_address)

    case apply_sys_call_fun(farm_proc.sys_call_fun, data) do
      {:ok, true} ->
        FarmProc.set_pc_ptr(farm_proc, FarmProc.get_cell_attr_as_pointer(farm_proc, pc, :___then))

      {:ok, false} ->
        FarmProc.set_pc_ptr(farm_proc, FarmProc.get_cell_attr_as_pointer(farm_proc, pc, :___else))

      :ok ->
        raise("Bad _if implementation.")

      {:error, reason} ->
        Ops.crash(farm_proc, reason)
    end
  end

  @spec nothing(FarmProc.t()) :: FarmProc.t()
  def nothing(%FarmProc{} = farm_proc) do
    Ops.next_or_return(farm_proc)
  end

  @spec execute(FarmProc.t()) :: FarmProc.t()
  def execute(farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page)
    sequence_id = FarmProc.get_cell_attr(farm_proc, pc, :sequence_id)
    next_ptr = FarmProc.get_next_address(farm_proc, pc)

    if FarmProc.has_page?(farm_proc, sequence_id) do
      farm_proc
      |> FarmProc.push_rs(next_ptr)
      |> FarmProc.set_pc_ptr(Pointer.new(sequence_id, Address.new(1)))
    else
      # Step 0: Unslice current address.
      data = Csvm.AST.Unslicer.run(heap, pc.heap_address)
      # Step 1: Get a copy of the sequence.
      case apply_sys_call_fun(farm_proc.sys_call_fun, data) do
        {:ok, %AST{} = sequence} ->
          # Step 2: Push PC -> RS
          # Step 3: Slice it
          new_heap = Csvm.AST.Slicer.run(sequence)

          FarmProc.push_rs(farm_proc, next_ptr)
          # Step 4: Add the new page.
          |> FarmProc.new_page(sequence_id, new_heap)
          # Step 5: Set PC to Ptr(1, 1)
          |> FarmProc.set_pc_ptr(Pointer.new(sequence_id, Address.new(1)))

        {:error, reason} ->
          Ops.crash(farm_proc, reason)

        _ ->
          raise("Bad execute implementation.")
      end
    end
  end
end

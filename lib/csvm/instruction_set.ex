defmodule Csvm.InstructionSet do
  alias Csvm.{
    AST,
    FarmProc,
    Instruction,
    InstructionSet,
    SysCallHandler,
    Resolver
  }

  import Csvm.Utils
  import Instruction, only: [simple_io_instruction: 1]
  import SysCallHandler, only: [apply_sys_call_fun: 2]

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
      farm_proc = FarmProc.clear_io_result(farm_proc)

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
      |> FarmProc.set_pc_ptr(Pointer.null(FarmProc.get_zero_page(farm_proc)))
      # Set status to crashed, return the farmproc
      |> FarmProc.set_status(:crashed)
      |> FarmProc.set_crash_reason(reason)
    end
  end

  simple_io_instruction(:move_relative)

  def move_absolute(%FarmProc{} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page_address)
    data = AST.unslice(heap, pc.heap_address)

    data =
      if data.args.location.kind == :identifier do
        Resolver.resolve(farm_proc, pc, data.args.location.args.label)
      else
        data
      end

    case farm_proc.io_result do
      nil ->
        latch = apply_sys_call_fun(farm_proc.sys_call_fun, data)

        FarmProc.set_status(farm_proc, :waiting)
        |> FarmProc.set_io_latch(latch)

      :ok ->
        InstructionSet.Ops.next_or_return(farm_proc)

      {:ok, %AST{} = result} ->
        latch =
          apply_sys_call_fun(
            farm_proc.sys_call_fun,
            AST.new(:move_absolute, %{location: result}, [])
          )

        FarmProc.set_status(farm_proc, :waiting)
        |> FarmProc.set_io_latch(latch)

      {:error, reason} ->
        InstructionSet.Ops.crash(farm_proc, reason)

      other ->
        raise "Bad return value: #{inspect(other)}"
    end
  end

  simple_io_instruction(:write_pin)
  simple_io_instruction(:read_pin)
  simple_io_instruction(:wait)
  simple_io_instruction(:find_home)
  simple_io_instruction(:send_message)
  simple_io_instruction(:read_status)
  simple_io_instruction(:set_user_env)
  simple_io_instruction(:sync)

  @spec sequence(FarmProc.t()) :: FarmProc.t()
  def sequence(%FarmProc{} = farm_proc) do
    body_addr =
      FarmProc.get_body_address(
        farm_proc,
        FarmProc.get_pc_ptr(farm_proc)
      )

    if FarmProc.is_null_address?(body_addr) do
      Ops.return(farm_proc)
    else
      Ops.call(farm_proc, body_addr)
    end
  end

  @spec _if(FarmProc.t()) :: FarmProc.t()
  def _if(%FarmProc{io_result: nil} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page_address)
    data = Csvm.AST.Unslicer.run(heap, pc.heap_address)
    latch = apply_sys_call_fun(farm_proc.sys_call_fun, data)

    farm_proc
    |> FarmProc.set_status(:waiting)
    |> FarmProc.set_io_latch(latch)
  end

  def _if(%FarmProc{io_result: result} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)

    case result do
      {:ok, true} ->
        FarmProc.set_pc_ptr(
          farm_proc,
          FarmProc.get_cell_attr_as_pointer(farm_proc, pc, :___then)
        )
        |> FarmProc.clear_io_result()

      {:ok, false} ->
        FarmProc.set_pc_ptr(
          farm_proc,
          FarmProc.get_cell_attr_as_pointer(farm_proc, pc, :___else)
        )
        |> FarmProc.clear_io_result()

      :ok ->
        raise("Bad _if implementation.")

      {:error, reason} ->
        Ops.crash(farm_proc, reason)
    end
  end

  @spec nothing(FarmProc.t()) :: FarmProc.t()
  def nothing(%FarmProc{} = farm_proc) do
    # tos         = List.last(farm_proc.rs)
    # pc          = FarmProc.get_pc_ptr(farm_proc)
    # is_whatever = tos == pc
    results = Ops.next_or_return(farm_proc)
    pc = FarmProc.get_pc_ptr(results)
    kind = FarmProc.get_kind(results, pc)

    if kind == :nothing do
      FarmProc.set_status(results, :done)
    else
      results
    end
  end

  @spec execute(FarmProc.t()) :: FarmProc.t()
  def execute(%FarmProc{io_result: nil} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page_address)
    sequence_id = FarmProc.get_cell_attr(farm_proc, pc, :sequence_id)
    next_ptr = FarmProc.get_next_address(farm_proc, pc)

    if FarmProc.has_page?(farm_proc, addr(sequence_id)) do
      farm_proc
      |> FarmProc.push_rs(next_ptr)
      |> FarmProc.set_pc_ptr(ptr(sequence_id, 1))
    else
      # Step 0: Unslice current address.
      data = AST.unslice(heap, pc.heap_address)
      latch = apply_sys_call_fun(farm_proc.sys_call_fun, data)

      farm_proc
      |> FarmProc.set_status(:waiting)
      |> FarmProc.set_io_latch(latch)
    end
  end

  def execute(%FarmProc{io_result: result} = farm_proc) do
    pc = FarmProc.get_pc_ptr(farm_proc)
    sequence_id = FarmProc.get_cell_attr(farm_proc, pc, :sequence_id)
    next_ptr = FarmProc.get_next_address(farm_proc, pc)
    # Step 1: Get a copy of the sequence.
    case result do
      {:ok, %AST{} = sequence} ->
        # Step 2: Push PC -> RS
        # Step 3: Slice it
        new_heap = Csvm.AST.Slicer.run(sequence)

        FarmProc.push_rs(farm_proc, next_ptr)
        # Step 4: Add the new page.
        |> FarmProc.new_page(addr(sequence_id), new_heap)
        # Step 5: Set PC to Ptr(1, 1)
        |> FarmProc.set_pc_ptr(ptr(sequence_id, 1))
        |> FarmProc.clear_io_result()

      {:error, reason} ->
        Ops.crash(farm_proc, reason)

      _ ->
        raise("Bad execute implementation.")
    end
  end
end

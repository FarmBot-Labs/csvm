defmodule Csvm.Instruction do
  alias Csvm.FarmProc
  import Csvm.SysCallHandler, only: [apply_sys_call_fun: 2]

  defmacro simple_io_instruction(instruction_name) do
    quote do
      @spec unquote(instruction_name)(FarmProc.t()) :: FarmProc.t()
      def unquote(instruction_name)(%FarmProc{} = farm_proc) do
        case farm_proc.io_result do
          nil ->
            pc = FarmProc.get_pc_ptr(farm_proc)
            heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page)
            data = Csvm.AST.Unslicer.run(heap, pc.heap_address)
            latch = Csvm.SysCallHandler.apply_sys_call_fun(farm_proc.sys_call_fun, data)
            FarmProc.set_status(farm_proc, :waiting)
            |> FarmProc.set_io_latch(latch)
          :ok -> Csvm.InstructionSet.Ops.next_or_return(farm_proc)
          {:ok, result} -> raise "Cant handle results..."
          {:error, reason} -> Csvm.InstructionSet.Ops.crash(farm_proc, reason)
        end
      end
    end
  end
end

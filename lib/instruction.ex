defmodule Csvm.Instruction do
  alias Csvm.FarmProc
  import Csvm.SysCallHandler, only: [apply_sys_call_fun: 2]

  defmacro simple_io_instruction(instruction_name) do
    quote do
      @spec unquote(instruction_name)(FarmProc.t()) :: FarmProc.t()
      def unquote(instruction_name)(%FarmProc{} = farm_proc) do
        pc = FarmProc.get_pc_ptr(farm_proc)
        heap = FarmProc.get_heap_by_page_index(farm_proc, pc.page)
        data = Csvm.AST.Unslicer.run(heap, pc.heap_address)
        result = apply_sys_call_fun(farm_proc.sys_call_fun, data)
        new_farm_proc = handle_io_result(farm_proc, result)
        Csvm.InstructionSet.Ops.next_or_return(new_farm_proc)
      end
    end
  end
end

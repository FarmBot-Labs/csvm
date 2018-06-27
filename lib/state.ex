defmodule Csvm.State do
  defstruct [:interaction_handler, :code]

  def incr_count(state) do
    %{ state | counter: state.counter + 1 }
  end

  def add_code(state, ast) do
    code = Map.put(state.code,
                   state.counter,
                   Csvm.AST.Slicer.run(ast))
    %{ state | code: code }
  end
end

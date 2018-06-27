defmodule Csvm.TestSupport.Fixtures do
  def master_sequence do
    File.read!("fixture/master_sequence.term") |> :erlang.binary_to_term()
  end
end

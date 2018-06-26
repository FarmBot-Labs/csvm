defmodule Csvm do
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, init_state()}
  end

  defp init_state do
    %{
      :tick => 0
    }
  end
end

defmodule Csvm.Server do
  use GenServer

  def echo(data) do
    GenServer.call(__MODULE__, {:echo, data})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    exe = Path.join(:code.priv_dir(:csvm), "mruby") |> to_charlist()
    mrb = Path.join([:code.priv_dir(:csvm), "csvm"])
    port = Port.open({:spawn_executable, exe}, [:exit_status, :binary, args: ["-b", mrb]])
    {:ok, port}
  end

  def handle_info({port, {:data, data}}, port) do
    IO.puts("DATA FROM MRUBY: #{inspect(data)}")
    {:noreply, port}
  end

  def handle_call({:echo, data}, _, port) do
    Port.command(port, data <> "\n")
    {:reply, :ok, port}
  end
end

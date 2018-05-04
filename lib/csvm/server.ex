defmodule Csvm.Server do
  use GenServer

  def echo(data) do
    GenServer.call(__MODULE__, {:echo, data})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    sh = Path.join(:code.priv_dir(:csvm), "mruby.sh") |> to_charlist()
    exe = Path.join(:code.priv_dir(:csvm), "mruby") |> to_charlist()
    mrb = Path.join([:code.priv_dir(:csvm), "mrb", "hello_world.mrb"])
    port = Port.open({:spawn_executable, sh}, [:exit_status, :binary, args: [exe, "-b", mrb]])
    {:ok, port}
  end

  def handle_info({port, {:data, data}}, port) do
    IO.puts "DATA FROM MRUBY: #{inspect data}"
    {:noreply, port}
  end

  def handle_call({:echo, data}, _, port) do
    Port.command(port, data <> "\n")
    {:reply, :ok, port}
  end

end

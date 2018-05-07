defmodule Mix.Tasks.MiniTest do
  use Mix.Task
  @moduledoc "Helper for running Mruby tests."
  @shortdoc @moduledoc

  def run(_) do
    Mix.shell().info([:yellow, "Starting Minitest"])
    mruby_exe = Path.join([:code.priv_dir(:csvm), "mruby"])
    wildcard = Path.join([:code.priv_dir(:csvm), "mrb", "*_test.mrb"])
    files = Path.wildcard(wildcard)

    for mruby_test_bin <- files do
      Mix.shell().info([:yellow, "Testing #{mruby_test_bin}"])
      System.cmd(mruby_exe, ["-b", mruby_test_bin], into: IO.stream(:stdio, :line))
    end
  end
end

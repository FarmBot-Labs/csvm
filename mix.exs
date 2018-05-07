defmodule Csvm.MixProject do
  use Mix.Project

  def project do
    [
      app: :csvm,
      version: "0.1.0",
      elixir: "~> 1.6",
      preferred_cli_env: [test: :test, mini_test: :test],
      dialyzer: [plt_add_deps: :apps_direct, plt_add_apps: [:mix]],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: ["lib", "test/test_support"],
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      make_env: make_env(),
      make_error_message: "",
      deps: deps()
    ]
  end

  defp make_env() do
    case System.get_env("ERL_EI_INCLUDE_DIR") do
      nil ->
        %{
          "ERL_EI_INCLUDE_DIR" => "#{:code.root_dir()}/usr/include",
          "ERL_EI_LIBDIR" => "#{:code.root_dir()}/usr/lib",
          "MIX_TARGET" => System.get_env("MIX_TARGET") || "host",
          "MIX_ENV" => to_string(Mix.env())
        }

      _ ->
        %{}
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Csvm.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4.0", runtime: false},
      {:dialyxir, "~> 0.5.1", runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end

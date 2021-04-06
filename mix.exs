defmodule Flamelex.MixProject do
  use Mix.Project

  def project do
    [
      app: :flamelex,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Flamelex.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
      {:scenic_layout_o_matic, "~> 0.4.0"},
      {:ecto_sql, "~> 3.0"},
      {:truetype_metrics, "~> 0.3"},
      {:font_metrics, "~> 0.3"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:gproc, "~> 0.5.0"}, #TODO remove gproc, use Registry
      {:tzdata, "~> 1.0.4"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      # source_url: "https://github.com/YourAcct/project",
      extras: ["README.md"]
      # groups_for_modules: groups_for_modules(),
      # extras: extras(),
      # groups_for_extras: groups_for_extras()
    ]
  end
end

defmodule Franklin.MixProject do
  use Mix.Project

  def project do
    [
      app: :franklin,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Flamelex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
      {:ecto_sql, "~> 3.0"},
      {:truetype_metrics, "~> 0.3"},
      {:font_metrics, "~> 0.3"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:gproc, "~> 0.5.0"}
    ]
  end
end

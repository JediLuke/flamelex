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

  #TODO use mix environments to figure out which memex to connect to?
  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [

      ## NOTE - these deps are all ones I have local copies of, so if you
      #         happn to be reading this (hello Vacarsu) you'll need to
      #         either clone them locally or switch back to the mix managed versions
      #
      #         I think you can just comment out memex for now, but, it might
      #         also break stuff

      #NOTE: These are the public declarations (pulled from github)
      # {:scenic, "~> 0.11.0-beta.0"},
      # {:scenic_driver_local, "~> 0.11.0-beta.0"},
      # {:memelex, git: "https://github.com/JediLuke/memelex"},
      #      These are the imports for local dev
      {:scenic, path: "../scenic", override: true},
      {:scenic_driver_local, path: "../scenic_driver_local", override: true},
      {:scenic_widget_contrib, path: "../scenic-widget-contrib", override: true},
      {:memelex, path: "../memelex"},
      # these deps should all be fine
      # {:scenic_layout_o_matic, "~> 0.4.0"},
      {:ecto_sql, "~> 3.0"},
      {:truetype_metrics, "~> 0.5"},
      {:font_metrics, "~> 0.5"},
      {:elixir_uuid, "~> 1.2"},
      {:wormhole, "~> 2.3"},
      {:jason, "~> 1.1"},
      {:gproc, "~> 0.5.0"}, #TODO remove gproc, use Registry
      {:tzdata, "~> 1.0.4"},
      {:event_bus, "~> 1.6.2"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:ice_cream, "~> 0.0.5", only: [:dev, :test]},
      {:stream_data, "~> 0.5", only: :test}
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

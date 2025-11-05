defmodule Flamelex.App.MixProject do
  use Mix.Project

  @version "0.4.67"

  def project do
    [
      app: :flamelex,
      version: @version,
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
      extra_applications: [:logger, :observer, :wx],
      mod: {Flamelex.App, []}
    ]
  end

  def version do
    @version
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # {:scenic, git: "https://github.com/JediLuke/scenic", branch: "update_deps_instructions_for_ubuntu_24", override: true},
      {:scenic, path: "../scenic", override: true},
      {:scenic_driver_local, git: "https://github.com/JediLuke/scenic_driver_local", branch: "flamelex_vsn"},
      {:scenic_widget_contrib, path: "../scenic-widget-contrib", override: true},
      {:quillex, path: "../quillex", runtime: false},
      {:memelex, path: "../memelex", runtime: false}, # TODO use same runtime false trick as above
      {:truetype_metrics, "~> 0.5"},
      {:font_metrics, "~> 0.5"},
      {:elixir_uuid, "~> 1.2"},
      {:wormhole, "~> 2.3"},
      {:jason, "~> 1.1"},
      {:tzdata, "~> 1.0.4"},
      {:event_bus, git: "https://github.com/JediLuke/event_bus", override: true},
      {:struct_access, "~> 1.1.2"}
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

      # {:stream_data, "~> 0.5", only: :test}


      # {:ex_doc, "~> 0.23", only: :dev, runtime: false},

      # {:map_diff, "~> 1.3"},
      # {:event_bus, "~> 1.6.2"},

      # {:scenic_layout_o_matic, "~> 0.4.0"},
      # {:ecto_sql, "~> 3.0"},

      # {:scenic_driver_local,
      #  git: "https://github.com/JediLuke/scenic_driver_local",
      #  branch: "luke_working",
      #  override: true},
      # {:scenic_driver_local, path: "../scenic_driver_local", override: true},
      # {:scenic_widget_contrib, path: "../scenic-widget-contrib", override: true},
      # {:memelex, git: "https://github.com/JediLuke/memelex"},
      # {:memelex, path: "../memelex"},
      # Quillex boot is managed explicitely be Flamelex so that we can
      # define certain environment variables before we try and boot the
      # GUI, so dont boot at runtime

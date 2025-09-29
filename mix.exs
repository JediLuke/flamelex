defmodule Flamelex.App.MixProject do
  use Mix.Project

  @version "0.4.9"

  def project do
    [
      app: :flamelex,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :inets],
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
      # {:scenic, git: "https://github.com/ScenicFramework/scenic.git", tag: "v0.11.1", override: true},
      {:scenic, path: "../scenic_local", override: true},
      # {:scenic_driver_local, git: "https://github.com/JediLuke/scenic_driver_local", branch: "no_line_wrap"},
      {:scenic_driver_local, git: "https://github.com/JediLuke/scenic_driver_local", branch: "flamelex_vsn", override: true},

      # {:scenic_widget_contrib, git: "https://github.com/JediLuke/scenic-widget-contrib", branch: "text_pad_wip", override: true},
      {:scenic_widget_contrib, path: "../scenic-widget-contrib", override: true},

      # import Quillex & Memelex
      # ** the reason runtime is false here is because, the boot sequence of
      #    these apps is managed explicitely by Flamelex, so that we can define
      #    certain variables before booting the GUI. Thus we dont boot at runtime
      # {:quillex, git: "https://github.com/JediLuke/quillex", runtime: false},
      {:quillex, path: "../quillex", runtime: false},
      # {:memelex, git: "https://github.com/JediLuke/memelex", runtime: false},
      {:memelex, path: "../memelex", runtime: false},

      # MCP server for AI automation
      # {:scenic_mcp, git: "https://github.com/scenic-contrib/scenic_mcp_experimental"},
      {:scenic_mcp, path: "../scenic_mcp", override: true},

      # one day, try this out again...
      # {:scenic_layout_o_matic, "~> 0.4.0"},

      # Flamelex deps
      {:truetype_metrics, "~> 0.5"},
      {:font_metrics, "~> 0.5"},
      {:elixir_uuid, "~> 1.2"},
      {:wormhole, "~> 2.3"},
      {:jason, "~> 1.1"},
      {:tzdata, "~> 1.0.4"},
      {:event_bus, git: "https://github.com/JediLuke/event_bus", override: true},
      {:struct_access, "~> 1.1.2"},

      # Spex testing framework for AI-driven development
      {:sexy_spex, path: "../spex", only: [:dev, :test]},
      
      # Live reload for Scenic development
      {:scenic_live_reload, "~> 0.3", only: :dev}

      # maybe one day we will bring these back
      # {:stream_data, "~> 0.5", only: :test}
      # {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      # {:map_diff, "~> 1.3"},
    ]
  end

  defp docs do
    [
      source_url: "https://github.com/JediLuke/flamelex",
      extras: ["README.md"]
      # groups_for_modules: groups_for_modules(),
      # extras: extras(),
      # groups_for_extras: groups_for_extras()
    ]
  end

  defp releases do
    [
      flamelex: [
        applications: [
          flamelex: :permanent,
          quillex: :permanent,
          memelex: :permanent,
          scenic_mcp: :permanent
        ],
        cookie: "flamelex_secure_cookie_#{System.get_env("USER", "default")}",
        quiet: true
      ]
    ]
  end
end

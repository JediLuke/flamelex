use Mix.Config

memex = "Paracelcus27"

config :memelex,
  active?: true,
  environment: %{
    name: memex,
    memex_directory: "/Users/luke/memex/#{memex}",
    backups_directory: "/Users/luke/memex/backups/#{memex}"
  }

config :logger, level: :debug

config :logger, truncate: :infinity

config :logger,
    :console,
        format: "[$level] $message $metadata\n",
        metadata: []
        

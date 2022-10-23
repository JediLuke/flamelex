use Mix.Config

config :logger, level: :debug

config :logger, truncate: :infinity

config :logger,
    :console,
        format: "[$level] $message $metadata\n",
        metadata: []
        

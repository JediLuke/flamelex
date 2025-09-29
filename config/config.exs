import Config

config :flamelex, :key_mapping, Flamelex.KeyMappings.VimClone


config :nx, default_backend: EXLA.Backend

config :event_bus,
  # https://github.com/otobus/event_bus/wiki/Creating-(Registering)-Topics
  topics: [
    # TODO rename this topic `flamelex-general`
    # This topic is used by Fluxus, it's for updating internal Fluxus state by firing actions #TODO rename this to `actions`?
    # :general,
    :flx_actions,
    # This topic is for transmitting user input throughout the application, to the appropriate listeners, which will likely in turn fire off Fluxus actions as a result of that input
    :flx_user_input,
    # The idea behind this topic is to handle external interrupts, e.g. perhaps we will add email as a feature to Flamelex, well getting an email might go on the interrupts channel
    :flx_interrupts
  ]

config :elixir,
       # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
       :time_zone_database,
       Tzdata.TimeZoneDatabase

config :scenic,
       :assets,
       module: Flamelex.App.Scenic.Assets

# Configure scenic_mcp port for Flamelex
config :scenic_mcp, 
  port: 9999,
  app_name: "Flamelex"

config :logger,
  level: :info,
  truncate: :infinity,
  # remove superfluous newline characters from logs, see: https://elixirforum.com/t/why-does-logger-output-in-iex-have-to-have-an-empty-line-after-every-line-logged/21822/4
  console: [format: "$time $metadata[$level] $message\n"]

# config :fluxus,
#   # actions_topic: :flx_actions,
#   # user_input_topic: :flx_user_input,
#   # interrupts_topic: :flx_interrupts,
#   radix_state: Flamelex.Fluxus.RadixState,
#   radix_reducer: Flamelex.Fluxus.RadixReducer

import_config "#{config_env()}.exs"

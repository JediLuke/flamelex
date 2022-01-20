import Config

config :elixir,
  # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
  :time_zone_database, Tzdata.TimeZoneDatabase

config :scenic,
  :assets, module: Flamelex.Assets

config :flamelex,
  :key_mapping, Flamelex.API.KeyMappings.VimClone

config :memelex,
  active?: false,
  environment: %{
    name: "Beauregard",
    memex_directory: "/Users/luke/memex/Beauregard",
    backups_directory: "/Users/luke/memex/backups/Beauregard"
  }

# remove superfluous newline characters from logs
# see: https://elixirforum.com/t/why-does-logger-output-in-iex-have-to-have-an-empty-line-after-every-line-logged/21822/4
config :logger,
  :console, format: "$time $metadata[$level] $levelpad$message\n"

# https://github.com/otobus/event_bus/wiki/Creating-(Registering)-Topics
config :event_bus,
  topics: [:general]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

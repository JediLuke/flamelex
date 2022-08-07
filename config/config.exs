import Config

config :elixir,
  # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
  :time_zone_database, Tzdata.TimeZoneDatabase

config :scenic,
  :assets, module: Flamelex.Assets

config :flamelex,
  :key_mapping, Flamelex.KeyMappings.VimClone

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
  topics: [
    :general,         # This topic is used by Fluxus, it's for updating internal Fluxus state by firing actions #TODO rename this to `actions`?
    :user_input,      # This topic is for transmitting user input throughout the application, to the appropriate listeners, which will likely in turn fire off Fluxus actions as a result of that input
    :interrupts       # The idea behind this topic is to handle external interrupts, e.g. perhaps we will add email as a feature to Flamelex, well getting an email might go on the interrupts channel
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

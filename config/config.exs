import Config


config :elixir,
  # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
  :time_zone_database, Tzdata.TimeZoneDatabase

config :scenic,
  :assets, module: Flamelex.Assets

config :flamelex,
  :key_mapping, Flamelex.API.KeyMappings.VimClone

# config :memex,
#   environment: %{
#     name: "Nicholas",
#     memex_directory: "/Users/luke/memex/Nicholas",
#     backups_directory: "/Users/luke/memex/backups/Nicholas"
#   }

config :memex,
  environment: %{
    name: "JediLuke",
    memex_directory: "/Users/luke/memex/JediLuke_copy",
    # backups_directory: "/Users/luke/memex/backups/JediLuke"
  }

# remove superfluous newline characters from logs
# see: https://elixirforum.com/t/why-does-logger-output-in-iex-have-to-have-an-empty-line-after-every-line-logged/21822/4
config :logger,
  :console, format: "$time $metadata[$level] $levelpad$message\n"

# https://github.com/otobus/event_bus/wiki/Creating-(Registering)-Topics
config :event_bus,
  topics: [
    # :checkout_completed, 
    # :email_sent,
    # :payment_failed, 
    # :user_created, 
    # :user_activated,  
    # more topics...
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

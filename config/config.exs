import Config

config :elixir,
  # https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database
  :time_zone_database, Tzdata.TimeZoneDatabase


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

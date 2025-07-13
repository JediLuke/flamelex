import Config

# Development environment - use Archimedes memex
config :memelex,
  active?: true,
  environment: %{
    # https://en.wikipedia.org/wiki/Archimedes
    name: "Archimedes",
    memex_directory: "/Users/luke/memex/dev/Archimedes",
    backups_directory: "/Users/luke/memex/backups/dev/Archimedes"
  }

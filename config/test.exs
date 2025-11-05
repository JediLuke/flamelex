import Config

# Test environment - use Lavoisier memex
config :memelex,
  active?: true,
  environment: %{
    # https://en.wikipedia.org/wiki/Antoine_Lavoisier
    name: "Lavoisier",
    memex_directory: "/Users/luke/memex/test/Lavoisier",
    backups_directory: "/Users/luke/memex/backups/test/Lavoisier"
  }

# Use different port for scenic_mcp in test environment to avoid conflicts
config :scenic_mcp, port: 9998

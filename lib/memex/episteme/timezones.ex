defmodule Flamelex.Memex.Episteme.TimeZones do
  @moduledoc """
  My knowledge of all things to do with Time-zones lives here.

  See also:
    - https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    - https://gist.github.com/aviflax/a4093965be1cd008f172
  """

  # https://en.wikipedia.org/wiki/Time_in_Texas
  def texas, do: "America/Chicago" # Central Time

  # https://en.wikipedia.org/wiki/Time_in_Australia
  def perth, do: "Australia/Perth" # Australian Western Standard Time

end

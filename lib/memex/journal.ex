defmodule Flamelex.Memex.Journal do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.CommonDeclarations

  def todays_entry do
    #TODO look up current month module, then find current day function (create it if it doesn't exist)
    raise "it should also show up in the GUI"
  end

  def timestamp do
    now = Memex.My.current_time()

    minute            = now.minute |> digit_to_string()
    hour              = now.hour   |> digit_to_string()
    month             = now.month  |> Utilities.DataTimeExtraUtils.month_name()
    year              = now.year   |> Integer.to_string()
    day_of_the_month  = now.day    |> digit_to_string()
    day_of_the_week   = now        |> DateTime.to_date()
                                   |> Date.day_of_week()
                                   |> Utilities.DataTimeExtraUtils.day_name()

    month <> year <>
      "-" <> day_of_the_week <> day_of_the_month <>
        "-" <> hour <> ":" <> minute
  end

  defp digit_to_string(x) when x in [1,2,3,4,5,6,7,8,9] do
    "0" <> Integer.to_string(x)
  end
  defp digit_to_string(x) do
    Integer.to_string(x)
  end
end

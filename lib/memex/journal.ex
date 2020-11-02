defmodule Flamelex.Memex.Journal do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.ProjectAliases

  @journal_month Journal.October2020

  @my_memex Flamelex.Memex.My.memex_env()

  def punctuated_quote do
    q = Memex.random_quote()

    ~s(“#{q.text}”
     - #{q.author}

    )
  end

  def now do

    #TODO This needs to find todays Journal entry & open it in a text buffer
    # journal_entry = hd(Flamelex.Memex.Episteme.EckhartTolle.quotes()).text
    journal_entry = punctuated_quote()



    Buffer.load(:text, journal_entry, %{
      name: "journal-now",
      open_in_gui?: true
    })
  end

  def today do
    @my_memex.timezone
    |> DateTime.now!()
  end

  def todays_entry do
    #TODO hey this is pretty neat!!!
    #TODO would be cooler if auto-loadable at runtime ?
    Module.concat(@my_memex, @journal_month).friday10_text()
  end

  def timestamp do
    now = Memex.My.current_time()

    minute            = now.minute |> digit_to_string()
    hour              = now.hour   |> digit_to_string()
    month             = now.month  |> Utilities.DateTimeExtraUtils.month_name()
    year              = now.year   |> Integer.to_string()
    day_of_the_month  = now.day    |> digit_to_string()
    day_of_the_week   = now        |> DateTime.to_date()
                                   |> Date.day_of_week()
                                   |> Utilities.DateTimeExtraUtils.day_name()

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

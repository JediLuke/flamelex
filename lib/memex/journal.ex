defmodule Flamelex.Memex.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases


  @doc """
  Uses the local time to figure out the filename of todays Journal entry.
  """
  def todays_page do

    now       = now_as_map()
    memex_id  = Flamelex.API.Memex.current_env().id

    journal_dir =
      Flamelex.Utils.RuntimeTools.project_root_dir()
      |> Path.join("/lib/memex/environments/" <> memex_id)
      |> Path.join("/journal")
      |> Path.join(now.year <> "/" <> now.month)

    # create this months journal entries directory, if it doesn't exist yet
    if not (journal_dir |> File.exists?()) do
      File.mkdir_p(journal_dir)
    end

    todays_journal_entry_filepath =
      journal_dir
      |> Path.join("/" <> now.todays_00day)

    todays_journal_entry_filepath # return value
  end

  def punctuated_quote do
    q = Memex.random_quote()
    ~s(“#{q.text}”\n   - #{q.author}\n\n)
  end


  def timestamp do
    n = now_as_map()

    n.month <> n.year <> "-" <> n.day_of_the_week <> n.day_of_the_month
      <> "-" <> n.hour <> ":" <> n.minute
  end

  defp now_as_map do
    now = Flamelex.API.Memex.My.current_time()

    minute            = now.minute |> digit_to_string()
    hour              = now.hour   |> digit_to_string()
    month             = now.month  |> Flamelex.Utilities.DateTimeExtraUtils.month_name()
    year              = now.year   |> Integer.to_string()
    day_of_the_month  = now.day    |> digit_to_string()
    day_of_the_week   = now        |> DateTime.to_date()
                                   |> Date.day_of_week()
                                   |> Flamelex.Utilities.DateTimeExtraUtils.day_name()
    todays_00day      = day_of_the_month <> "-" <> day_of_the_week


    %{
      minute: minute,
      hour: hour,
      month: month,
      year: year,
      day_of_the_month: day_of_the_month,
      day_of_the_week: day_of_the_week,
      todays_00day: todays_00day # always return day of the month as double digits
    }
  end

  def new_journal_entry_template() do
    now = now_as_map()

    punctuated_quote() <>
    now.day_of_the_week<>", "<>now.day_of_the_month<>" of "<>now.month<>"\n\n"<>
    now.hour<>":"<>now.minute<>"\n\n"
  end

  defp digit_to_string(x) when x in [1,2,3,4,5,6,7,8,9] do
    "0" <> Integer.to_string(x)
  end
  defp digit_to_string(x) when is_integer(x) and x > 1 and x < 32 do
    Integer.to_string(x)
  end
end

defmodule Flamelex.Memex.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases


  #TODO programatically get this instead of hard-coding it
  @project_root_dir "/Users/luke/workbench/elixir/flamelex"
  @memex_environment_dir @project_root_dir |> Path.join("/lib/memex/environments/jediluke")
  @journal_dir @memex_environment_dir |> Path.join("/journal")


  # def open_journal_entry(:today) do
  #   now = now_as_map()

  #   current_journal_dir = @journal_dir
  #                         |> Path.join(now.year <> "/" <> now.month)

  #   if not (current_journal_dir |> File.exists?()) do
  #     File.mkdir_p(current_journal_dir)
  #   end

  #   #TODO scan the file, look for most recent timestamp - if it's more than 15? minutes, append a new one
  #   todays_journal_entry_file = current_journal_dir |> Path.join("/" <> now.todays_day)

  #   if todays_journal_entry_file |> File.exists?() do
  #     Flamelex.API.Buffer.open!(todays_journal_entry_file)
  #   else
  #     journal_entry = generate_new_journal_entry_for_today()

  #     {:ok, file} = File.open(todays_journal_entry_file, [:write])
  #     IO.binwrite(file, journal_entry)
  #     :ok = File.close(file)

  #     Flamelex.API.Buffer.open!(todays_journal_entry_file)
  #   end
  # end

  @doc """
  Uses the local time to figure out the filename of todays Journal entry.
  """
  def todays_page do
    now = now_as_map()

    current_journal_dir = @journal_dir
                          |> Path.join(now.year <> "/" <> now.month)

    if not (current_journal_dir |> File.exists?()) do
      File.mkdir_p(current_journal_dir)
    end

    todays_journal_entry_filepath =
                current_journal_dir |> Path.join("/" <> now.todays_00day)

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
    now = Flamelex.Memex.My.current_time()

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
      todays_00day: todays_00day
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
  defp digit_to_string(x) do
    Integer.to_string(x)
  end
end

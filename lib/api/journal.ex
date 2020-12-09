defmodule Flamelex.API.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases

  # @journal_month Journal.October2020

  # @my_memex Flamelex.Memex.My.memex_env()


  #TODO programatically get this instead of hard-coding it
  @project_root_dir "/Users/luke/workbench/elixir/flamelex"
  @memex_environment_dir @project_root_dir |> Path.join("/lib/memex/environments/jediluke")
  @journal_dir @memex_environment_dir |> Path.join("/journal")

  # /Users/luke/workbench/elixir/flamelex/

  def punctuated_quote do
    q = Memex.random_quote()

    ~s(“#{q.text}”\n   - #{q.author}\n\n)
  end

  def today do
    now()
  end

  def now do
    now = Flamelex.Memex.My.current_time()

    minute            = now.minute |> digit_to_string()
    hour              = now.hour   |> digit_to_string()
    month             = now.month  |> Flamelex.Utilities.DateTimeExtraUtils.month_name()
    year              = now.year   |> Integer.to_string()
    day_of_the_month  = now.day    |> digit_to_string()
    day_of_the_week   = now        |> DateTime.to_date()
                                   |> Date.day_of_week()
                                   |> Flamelex.Utilities.DateTimeExtraUtils.day_name()

    #TODO scan the file, look for most recent timestamp - if it's more than 15? minutes, append a new one

    current_journal_dir = @journal_dir |> Path.join(year <> "/" <> month)

    if not (current_journal_dir |> File.exists?()) do
      File.mkdir_p(current_journal_dir)
    end

    todays_day = day_of_the_month <> "-" <> day_of_the_week
    todays_journal_entry_file = current_journal_dir |> Path.join("/" <> todays_day)


    if todays_journal_entry_file |> IO.inspect() |> File.exists?() do
      IO.puts "OPENING THE EXISTING FILE!!"
      Buffer.open!(todays_journal_entry_file)
    else
      # need to create the entry
      IO.puts "NEED TO CREATE THE ENTRY"
      journal_entry = punctuated_quote() <> day_of_the_week <> ", " <> day_of_the_month <> " of " <> month <> "\n\n" <> hour <> ":" <> minute <> "\n\n"

      {:ok, file} = File.open(todays_journal_entry_file, [:write])
      IO.binwrite(file, journal_entry)
      :ok = File.close(file)

      Buffer.open!(todays_journal_entry_file)
    end
  end

  # def today do
  #   @my_memex.timezone
  #   |> DateTime.now!()
  # end

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

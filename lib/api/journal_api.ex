defmodule Flamelex.API.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases


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

  def now do
    todays_page_filepath = Flamelex.Memex.Journal.todays_page()

    if not File.exists?(todays_page_filepath) do
      # create the file since it doesn't exist...
      {:ok, file} = File.open(todays_page_filepath, [:write])
      IO.binwrite(file, Flamelex.Memex.Journal.new_journal_entry_template())
      File.close(file)
    end

    Flamelex.Fluxus.fire_action({:open_buffer, %{
      type: Flamelex.Buffer.Text,
      source: {:file, todays_page_filepath},
      label: "journal-today",
      open_in_gui?: true, #TODO set active buffer
      append_new_timestamp?: false #TODO scan the file, look for most recent timestamp - if it's more than 15? minutes, append a new one
      # make_active_buffer?: true
    }})

    #TODO here we need to get a callback when Journal opens, and return a ref to the caller
    # i.e. j = Journal.now()
    #      Buffer.read(j)
    #
    # should work
  end
end

defmodule Flamelex.API.Journal do
  @moduledoc """
  The interface to the Memex journal.
  """
  use Flamelex.ProjectAliases


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
  end
end

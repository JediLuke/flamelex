defmodule Flamelex.Fluxus.Reducers.Journal do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Memex.Journal


  # def async_reduce(_radix_state, {:action, {:journal, :today}}) do
  #   Flamelex.Memex.Journal.open_journal_entry(:today)
  #   :ok
  # end


  def async_reduce(_radix_state, :open_todays_journal_entry) do
    if filepath = Journal.todays_page() |> File.exists?() do
      fire_open_buffer_action(filepath)
    else
      # create the file since it doesn't exist...
      {:ok, file} = File.open(Journal.todays_page, [:write])
      IO.binwrite(file, Journal.new_journal_entry_template())
      File.close(file)

      fire_open_buffer_action(file)
    end
  end

  def async_reduce(_radix_state, _a) do
    :ignoring_action
  end

  defp fire_open_buffer_action(filepath) do
    Flamelex.Fluxus.fire_action({:open_buffer, %{
      type: Flamelex.Buffer.Text,
      source: {:file, filepath},
      label: "journal-today",
      open_in_gui?: true, #TODO set active buffer
      append_new_timestamp?: false #TODO scan the file, look for most recent timestamp - if it's more than 15? minutes, append a new one
      # make_active_buffer?: true
    }})
  end
end

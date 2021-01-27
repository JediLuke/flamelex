defmodule Flamelex.Fluxus.Reducers.Journal do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Memex.Journal


  # def async_reduce(_radix_state, {:action, {:journal, :today}}) do
  #   Flamelex.Memex.Journal.open_journal_entry(:today)
  #   :ok
  # end


  def async_reduce(_radix_state, :open_todays_journal_entry) do
    if Journal.todays_page |> File.exists?() do
      Flamelex.Fluxus.fire_action({
              :open_buffer,
                {:local_text_file, path: Journal.todays_page}, %{
                  label: "journal-today",
                  append_new_timestamp?: false #TODO scan the file, look for most recent timestamp - if it's more than 15? minutes, append a new one
              }})
    else
      journal_entry = Journal.new_journal_entry_template()

      {:ok, file} = File.open(Journal.todays_page, [:write])
      IO.binwrite(file, journal_entry)
      :ok = File.close(file)

      Flamelex.Fluxus.fire_action({
        :open_buffer!,
        {:local_file, path: Journal.todays_page},
        %{
          label: "journal - today",
          make_active_buffer?: true
        }
      })
    end
  end

  def async_reduce(_radix_state, a) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end

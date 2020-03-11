defmodule Franklin.Buffer.List do
  @moduledoc false
  use GenServer
  require Logger
  alias Utilities.DataFile

  def start_link(contents), do: GenServer.start_link(__MODULE__, contents)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(:notes) do
    Logger.info "#{__MODULE__} initializing... Displaying all notes..."

    state = DataFile.read()

    GUI.Scene.Root.action({'NEW_LIST_NOTES_BUFFER', state, buffer_pid: self()})
    {:ok, state}
  end
end

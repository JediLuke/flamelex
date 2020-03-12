defmodule Franklin.Buffer.TextEditor do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(data), do: GenServer.start_link(__MODULE__, data)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(data) do
    Logger.info "#{__MODULE__} initializing... #{inspect data}"

    state = %{
      component_pid: nil
    }

    GUI.Scene.Root.action({'NEW_BUFFER', type: :text_editor, buffer_pid: self()})
    {:ok, state}
  end
end

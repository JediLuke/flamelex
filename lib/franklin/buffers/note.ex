defmodule Franklin.Buffer.Note do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(contents), do: GenServer.start_link(__MODULE__, contents)
  def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
  def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
  def save(pid), do: GenServer.cast(pid, :save)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(contents) do
    state = contents |> Map.merge(%{
      uuid: UUID.uuid4(),
      focus: :title
    })

    Logger.info "#{__MODULE__} initializing... #{inspect state}"
    GUI.Scene.Root.action({'NEW_NOTE_COMMAND', contents, buffer_pid: self()})
    {:ok, state}
  end

  def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :title} = state) do
    state = %{state|title: state.title <> letter}
    GenServer.cast(scenic_component_pid, {'APPEND_INPUT_TO_TITLE', state}) #TODO make this a Note.something function
    {:noreply, state}
  end

  def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
    GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
    {:noreply, state}
  end
end

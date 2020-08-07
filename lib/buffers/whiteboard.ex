defmodule Franklin.Buffer.Whiteboard do
  @moduledoc false
  use GenServer
  require Logger
  # alias Utilities.DataFile

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  # def input(pid, {scenic_component_pid, input}),  do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  # def tab_key_pressed(pid),                       do: GenServer.cast(pid, :tab_key_pressed)
  # def reverse_tab(pid),                           do: GenServer.cast(pid, :reverse_tab)
  # def set_mode(pid, :command),                    do: GenServer.cast(pid, :activate_command_mode)
  # def save_and_close(pid),                        do: GenServer.cast(pid, :save_and_close)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%{title: _title, text: _text} = contents) do

    #TODO new Buffer struct
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
    GUI.Component.Note.append_text(scenic_component_pid, :title, state)
    {:noreply, state}
  end

  def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :text} = state) do
    state = %{state|text: state.text <> letter}
    GUI.Component.Note.append_text(scenic_component_pid, :text, state)
    {:noreply, state}
  end

  def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
    GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
    new_state = %{state|focus: :text}
    {:noreply, new_state}
  end

  def handle_cast(:save_and_close, state) do
    DataFile.read()
      |> Map.merge(%{
           state.uuid => %{
             title: state.title,
             text: state.text,
             datetime_utc: DateTime.utc_now(),
             #TODO hash entire contents
             #TODO handle timezones
             tags: ["note"]
           },
         })
      |> DataFile.write()

    GUI.Scene.Root.action({:active_buffer, :note, 'CLOSE_NOTE_BUFFER'})
    {:noreply, state}
  end

  def handle_cast(:tab_key_pressed, %{focus: :text} = state) do
    Logger.warn "Text area doesn't handle tab character just yet..."
    {:noreply, state}
  end

  def handle_cast(:reverse_tab, %{focus: :text} = state) do
    Logger.warn "YES we got a shift+Tab in text though" #THIS WORKS!
    GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'})
    new_state = %{state|focus: :title}
    {:noreply, new_state}
  end
end

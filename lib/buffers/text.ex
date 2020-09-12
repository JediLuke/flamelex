defmodule Flamelex.Buffer.Text do
  @moduledoc false
  use GenServer
  require Logger
  use Flamelex.CommonDeclarations


  def start_link(params) do
    buf  = Buffer.new(params)
    name = Utilities.ProcessRegistry.via_tuple(buf.name)
    GenServer.start_link(__MODULE__, buf, name: name)
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%Buffer{} = buf, open_buffer? \\ true) do
    Logger.info "#{__MODULE__} initializing... type: #{inspect buf.type}, name: #{buf.name}"
    if open_buffer?, do: GenServer.cast(self(), :show_in_gui)
    {:ok, buf}
  end

  def handle_cast(:show_in_gui, buf) do
    GUI.Controller.action({:show_in_gui, buf})
    {:noreply, buf}
  end

  # def handle_cast({:insert_char, char, after: x}, state) do

  #   inject_char =
  #     fn string ->
  #       {before_split, after_split} = string |> String.split_at(x)
  #       before_split <> char <> after_split
  #     end

  #   new_state =
  #     state
  #     |> Map.update!(:content, inject_char)

  #   {before_update, _after_split} = state.content |> String.split_at(20)
  #   {before_update_new, _after_split} = new_state.content |> String.split_at(20)

  #   IO.puts "B: #{before_update}\nN: #{before_update_new}"

  #   #TODO trigger re-draw
  #   GUI.Controller.show_fullscreen(new_state)

  #   {:noreply, new_state}
  # end

  # def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :text} = state) do
  #   state = %{state|text: state.text <> letter}
  #   GUI.Component.Note.append_text(scenic_component_pid, :text, state)
  #   {:noreply, state}
  # end

  # def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
  #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
  #   new_state = %{state|focus: :text}
  #   {:noreply, new_state}
  # end

  # def handle_cast(:save_and_close, state) do
  #   DataFile.read()
  #     |> Map.merge(%{
  #          state.uuid => %{
  #            title: state.title,
  #            text: state.text,
  #            datetime_utc: DateTime.utc_now(),
  #            #TODO hash entire contents
  #            #TODO handle timezones
  #            tags: ["note"]
  #          },
  #        })
  #     |> DataFile.write()

  #   GUI.Scene.Root.action({:active_buffer, :note, 'CLOSE_NOTE_BUFFER'})
  #   {:noreply, state}
  # end

  # def handle_cast(:tab_key_pressed, %{focus: :text} = state) do
  #   Logger.warn "Text area doesn't handle tab character just yet..."
  #   {:noreply, state}
  # end

  # def handle_cast(:reverse_tab, %{focus: :text} = state) do
  #   Logger.warn "YES we got a shift+Tab in text though" #THIS WORKS!
  #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'})
  #   new_state = %{state|focus: :title}
  #   {:noreply, new_state}
  # end

end

defmodule Franklin.Buffer.Text do
  @moduledoc false
  use GenServer
  require Logger
  alias Structs.Buffer
  # alias Utilities.DataFile
  # import Utilities.ProcessRegistry

  def start_link(params) do
    buf = Buffer.new(params)
    GenServer.start_link(__MODULE__, buf, name: via_tuple(buf.name))
  end

  # def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  # def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
  # def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
  # def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
  # def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)

  def insert(file_name, string, opts) when is_bitstring(file_name) do
    file_name
    |> Utilities.ProcessRegistry.fetch_buffer_pid!()
    |> insert(string, opts)
  end
  def insert(buffer_pid, string, [after: x]) when is_pid(buffer_pid) do
    buffer_pid
    |> GenServer.cast({:insert_char, string, after: x})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%Buffer{} = state) do
    Logger.info "#{__MODULE__} initializing... #{inspect state}"

    # state =
    #   content
    #   |> Map.merge(%{
    #     uuid: UUID.uuid4(),
    #     focus: :title
    #   })

    {:ok, state, {:continue, :initialize_gui}}
  end

  def handle_continue(:initialize_gui, state) do

    #TODO call Scenic GUI component process (registered to this topic/whatever) &

    # GUI.register_new_buffer(
    #   type: :text,
    #   content: content,
    #   action: 'OPEN_FULL_SCREEN'
    # ) #TODO use the gproc reference

    GUI.Controller.show_fullscreen(state)

    {:noreply, state}
  end

  def handle_cast({:insert_char, char, after: x}, state) do

    inject_char =
      fn string ->
        {before_split, after_split} = string |> String.split_at(x)
        before_split <> char <> after_split
      end

    new_state =
      state
      |> Map.update!(:content, inject_char)

    {before_update, _after_split} = state.content |> String.split_at(20)
    {before_update_new, _after_split} = new_state.content |> String.split_at(20)

    IO.puts "B: #{before_update}\nN: #{before_update_new}"

    #TODO trigger re-draw
    GUI.Controller.show_fullscreen(new_state)

    {:noreply, new_state}
  end

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

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:buffer, name}}}
  end
end

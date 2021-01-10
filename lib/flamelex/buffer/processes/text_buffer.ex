defmodule Flamelex.Buffer.Text do
  @moduledoc """
  A buffer to hold & manipulate text.
  """
  alias Flamelex.Structs.Buf

  # use Flamelex.BufferBehaviour

  use GenServer, restart: :temporary
  require Logger
  use Flamelex.ProjectAliases


  #TODO this looks like a nuce func for a behaviour...
  def start_link(%{ref: ref} = params) do
    case Buf.rego_tag(ref) do
      {:buffer, _ref} = tag ->
          name = ProcessRegistry.via_tuple_name(:gproc, tag)
          GenServer.start_link(__MODULE__, params, name: name)
      :error ->
          {:error, Buf.invalid_ref_param_error_string(params)}
    end
  end

  #TODO make this cast to itself, & get this process to do the GUI adjustment
  def move_cursor({:buffer, name}, {direction, distance}) do
    ProcessRegistry.find!({:gui_component, name})
    |> GenServer.cast({:move_cursor, direction, distance})
  end
  def move_cursor(:active_buffer, {direction, distance}) do
    ProcessRegistry.find!(:active_buffer)
    |> GenServer.cast({:action, {:move_cursor, direction, distance}})
  end
  def move_cursor(buf, position) when is_map(position) do
    ProcessRegistry.find!({:gui_component, buf})
    |> GenServer.cast({:move_cursor, position})
  end


  @impl GenServer
  def init(%{from_file: _filepath} = params) do
    Logger.debug "#{__MODULE__} initializing... params: #{inspect params}"

    # PubSub.subscribe(topic)

    {:ok, params, {:continue, :open_file_on_disk}}
  end

  # def init(%{name: ref, data: data, weird_thing: www}) do
  #   Logger.debug "#{__MODULE__} initializing..."

  #   IO.inspect www, label: "MAYTCJUY???????"

  #   #TODO need to register for PubSUb msgs

  #   new_buf = %{
  #     ref: ref,
  #     data: data,
  #     unsaved_changes?: false
  #   }

  #   {:ok, new_buf}
  # end

  @impl GenServer
  def handle_continue(:open_file_on_disk, %{from_file: filepath} = params) do

    {:ok, file_contents} = File.read(filepath)
    buf_ref = Buf.new(%{type: :text} |> Map.merge(params))

    new_buf = %{
      ref: buf_ref,
      data: file_contents,
      unsaved_changes?: false }

    # now, let's callback to the process which booted this one, to
    # say that we successfully loaded the file from disk
    send( params.after_boot_callback,
          {self(), :successfully_opened, filepath, buf_ref} ) #REMINDER: we send back `filepath` because we match on it like ^filepath

    {:noreply, new_buf}
  end

  @impl GenServer
  def handle_call(:read, _from, state) do
    {:reply, state.data, state}
  end

  def handle_call({:modify, {:insert, new_text, %{col: cursor_x, row: cursor_y}}}, _from, state) do

    insert_text_function =
        fn string ->
          list_of_text_lines = String.split(string, "\n")

          {this_line, _other_lines} = list_of_text_lines |> List.pop_at(cursor_y)

          {before_split, after_split} = this_line |> String.split_at(cursor_x)

          updated_line = before_split <> new_text <> after_split

          updated_list_of_text_lines = list_of_text_lines |> List.replace_at(cursor_y, updated_line)

          updated_list_of_text_lines |> Enum.join()
        end

    new_state =
        state
        |> Map.update!(:data, insert_text_function)
        |> Map.put(:unsaved_changes?, true)

    {:gui_component, new_state.name}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:refresh, new_state})

    move_cursor(new_state.name, %{row: cursor_x+1, col: 0})

    # Flamelex.GUI.Controller.refresh({:buffer, state.name})
    # Flamelex.GUI.Controller.show({:buffer, filepath}) #TODO this is just a request, top show a buffer. Once I really nail the way we're linking up buffers/components, come back & fix this

    {:reply, :ok, new_state}
  end

  def handle_call({:modify, {:insert, {:codepoint, {char, 0}}, cursor = {:cursor, 1}}}, _from, state) when is_bitstring(char) do

    #TODO
    # cursor_coords =
    #   ProcessRegistry.find!(Cursor.rego_tag(cursor))
    #   |> GenServer.call(:get_coords)

    insertion_site = 3 #TODO

    insert_text_function =
      fn string ->
        {before_split, after_split} = string |> String.split_at(insertion_site)
        before_split <> char <> after_split
      end

    new_state =
        state
        |> Map.update!(:data, insert_text_function)
        |> Map.put(:unsaved_changes?, true)

    Flamelex.GUI.Controller.refresh(new_state)

    {:reply, :ok, new_state}
  end

  def handle_call({:modify, {:insert, new_text, insertion_site}}, _from, state) when is_bitstring(new_text) and is_integer(insertion_site) do

    insert_text_function =
        fn string ->
          {before_split, after_split} = string |> String.split_at(insertion_site)
          before_split <> new_text <> after_split
        end

    new_state =
        state
        |> Map.update!(:data, insert_text_function)
        |> Map.put(:unsaved_changes?, true)

    Flamelex.GUI.Controller.refresh(new_state)

    {:reply, :ok, new_state}
  end

  #TODO so now we have the question, is the first position 0 or 1???
  def handle_call({:modify, {:delete, [from: a, to: b]}}, _from, state) when b >= a and a >= 0 do

    {before_split, _after_split} = state.data |> String.split_at(a)
    {_before_split, after_split} = state.data |> String.split_at(b)

    text_after_deletion = before_split <> after_split

    new_state =
        state
        |> Map.put(:data, text_after_deletion)

    Flamelex.GUI.Controller.refresh({:buffer, state.name})

    {:reply, :ok, new_state}
  end

  def handle_call(:save, _from, state) do

    {:ok, file} = File.open(state.name, [:write])
    IO.binwrite(file, state.data)
    :ok = File.close(file)

    new_state =
      state
      |> Map.put(:unsaved_changes?, false)

    {:reply, :ok, new_state}
  end

  def handle_cast(:close, state) do
    if state.unsaved_changes? do
      raise "need to be able to interact with the user here I guess..."
    else
      {:stop, :normal, state}
    end
  end


  # def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
  # def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
  # def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
  # def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
  # def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)




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

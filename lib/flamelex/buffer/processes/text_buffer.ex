defmodule Flamelex.Buffer.Text do
  @moduledoc """
  A buffer to hold & manipulate text.
  """
  use Flamelex.BufferBehaviour

  @impl Flamelex.BufferBehaviour
  def rego_tag(%{type: __MODULE__, ref: {:file, filepath}, from_file: same_filepath}) when filepath == same_filepath and is_bitstring(filepath) do
    # a unique reference, used to register the buffer process,
    # eg. {:file, "some/filepath"} or "lukesBuffer"
    {:buffer, {:file, filepath}}
  end

  # handle opening
  @impl Flamelex.BufferBehaviour
  def boot_sequence(%{
        type: __MODULE__,
   from_file: filepath,
   after_boot_callback: callback_pid
  } = params) when is_pid(callback_pid) do

    {:ok, file_contents} = File.read(filepath)

    buf_ref   = BufRef.new!(params)
    buf_state = BufferState.new!(params
                                 |> Map.merge(%{data: file_contents}))

    #NOTE: just checking here that both the BufRef and BufferState have the same `ref`...
    if buf_ref.ref != buf_state.ref do
      context = %{buf_ref: buf_ref, buf_state: buf_state, params: params}
      raise "a `ref` mismatch occured when booting a TextBuffer.\n\n#{inspect context}\n\n"
    end

    # now, let's callback to the process which booted this one, to
    # say that we successfully loaded the file from disk
    callback_pid #TODO this could just be BufferManager, save some complexity
    |> send({self(), :successfully_opened, filepath, buf_ref})
       #REMINDER: we send back `filepath` because we match on it like ^filepath

    {:noreply, buf_state}
  end

  #TODO with modify_buffer utils
  # def handle_call({:modify, {:insert, new_text, %{col: cursor_x, row: cursor_y}}}, _from, state) do

  #   insert_text_function =
  #       fn string ->
  #         list_of_text_lines = String.split(string, "\n")

  #         {this_line, _other_lines} = list_of_text_lines |> List.pop_at(cursor_y)

  #         {before_split, after_split} = this_line |> String.split_at(cursor_x)

  #         updated_line = before_split <> new_text <> after_split

  #         updated_list_of_text_lines = list_of_text_lines |> List.replace_at(cursor_y, updated_line)

  #         updated_list_of_text_lines |> Enum.join()
  #       end

  #   new_state =
  #       state
  #       |> Map.update!(:data, insert_text_function)
  #       |> Map.put(:unsaved_changes?, true)

  #   {:gui_component, new_state.name}
  #   |> ProcessRegistry.find!()
  #   |> GenServer.cast({:refresh, new_state})

  #   move_cursor(new_state.name, %{row: cursor_x+1, col: 0})

  #   # Flamelex.GUI.Controller.refresh({:buffer, state.name})
  #   # Flamelex.GUI.Controller.show({:buffer, filepath}) #TODO this is just a request, top show a buffer. Once I really nail the way we're linking up buffers/components, come back & fix this

  #   {:reply, :ok, new_state}
  # end

  # def handle_call({:modify, {:insert, {:codepoint, {char, 0}}, cursor = {:cursor, 1}}}, _from, state) when is_bitstring(char) do

  #   #TODO
  #   # cursor_coords =
  #   #   ProcessRegistry.find!(Cursor.rego_tag(cursor))
  #   #   |> GenServer.call(:get_coords)

  #   insertion_site = 3 #TODO

  #   insert_text_function =
  #     fn string ->
  #       {before_split, after_split} = string |> String.split_at(insertion_site)
  #       before_split <> char <> after_split
  #     end

  #   new_state =
  #       state
  #       |> Map.update!(:data, insert_text_function)
  #       |> Map.put(:unsaved_changes?, true)

  #   Flamelex.GUI.Controller.refresh(new_state)

  #   {:reply, :ok, new_state}
  # end

  # def handle_call({:modify, {:insert, new_text, insertion_site}}, _from, state) when is_bitstring(new_text) and is_integer(insertion_site) do

  #   insert_text_function =
  #       fn string ->
  #         {before_split, after_split} = string |> String.split_at(insertion_site)
  #         before_split <> new_text <> after_split
  #       end

  #   new_state =
  #       state
  #       |> Map.update!(:data, insert_text_function)
  #       |> Map.put(:unsaved_changes?, true)

  #   Flamelex.GUI.Controller.refresh(new_state)

  #   {:reply, :ok, new_state}
  # end

  # #TODO so now we have the question, is the first position 0 or 1???
  # def handle_call({:modify, {:delete, [from: a, to: b]}}, _from, state) when b >= a and a >= 0 do

  #   {before_split, _after_split} = state.data |> String.split_at(a)
  #   {_before_split, after_split} = state.data |> String.split_at(b)

  #   text_after_deletion = before_split <> after_split

  #   new_state =
  #       state
  #       |> Map.put(:data, text_after_deletion)

  #   Flamelex.GUI.Controller.refresh({:buffer, state.name})

  #   {:reply, :ok, new_state}
  # end

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

  # def handle_cast({:move_cursor, %{cursor_num: 1, instructions: {:down, 1, :line}}} = details, state) do

  #   #TODO once buffer name registration is solid, this becomes easy...
  #   IO.puts "OK, NOW WE GOTTA MOVE THE FKIN THING\n\n"

  #   ProcessRegistry.find!({:gui_component, state.name}) # then it will, in turn, forward the request to the cursor...
  #   |> GenServer.cast({:move_cursor, details})
  # end




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

end

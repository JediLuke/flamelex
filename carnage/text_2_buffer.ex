

#   def handle_call({:modify, {:insert, new_text, %{col: cursor_x, row: cursor_y}}}, _from, state) do

#     insert_text_function =
#         fn string ->
#           list_of_text_lines = String.split(string, "\n")

#           {this_line, _other_lines} = list_of_text_lines |> List.pop_at(cursor_y)

#           {before_split, after_split} = this_line |> String.split_at(cursor_x)

#           updated_line = before_split <> new_text <> after_split

#           updated_list_of_text_lines = list_of_text_lines |> List.replace_at(cursor_y, updated_line)

#           updated_list_of_text_lines |> Enum.join()
#         end

#     new_state =
#         state
#         |> Map.update!(:data, insert_text_function)
#         |> Map.put(:unsaved_changes?, true)

#     {:gui_component, new_state.name}
#     |> ProcessRegistry.find!()
#     |> GenServer.cast({:refresh, new_state})

#     move_cursor(new_state.name, %{row: cursor_x+1, col: 0})

#     # Flamelex.GUI.Controller.refresh({:buffer, state.name})
#     # Flamelex.GUI.Controller.show({:buffer, filepath}) #TODO this is just a request, top show a buffer. Once I really nail the way we're linking up buffers/components, come back & fix this

#     {:reply, :ok, new_state}
#   end

#   def handle_call({:modify, {:insert, new_text, insertion_site}}, _from, state) do

#     IO.puts "MODIFYING!!!"

#     insert_text_function =
#         fn string ->
#           {before_split, after_split} = string |> String.split_at(insertion_site)
#           before_split <> new_text <> after_split
#         end

#     new_state =
#         state
#         |> Map.update!(:data, insert_text_function)
#         |> Map.put(:unsaved_changes?, true)

#     # Flamelex.GUI.Controller.refresh({:buffer, state.name})
#     # Flamelex.GUI.Controller.show({:buffer, filepath}) #TODO this is just a request, top show a buffer. Once I really nail the way we're linking up buffers/components, come back & fix this

#     {:reply, :ok, new_state}
#   end

#   #TODO so now we have the question, is the first position 0 or 1???
#   def handle_call({:modify, {:delete, [from: a, to: b]}}, _from, state) when b >= a and a >= 0 do

#     {before_split, _after_split} = state.data |> String.split_at(a)
#     {_before_split, after_split} = state.data |> String.split_at(b)

#     text_after_deletion = before_split <> after_split

#     new_state =
#         state
#         |> Map.put(:data, text_after_deletion)

#     Flamelex.GUI.Controller.refresh({:buffer, state.name})

#     {:reply, :ok, new_state}
#   end

#   def handle_call(:save, _from, state) do

#     {:ok, file} = File.open(state.name, [:write])
#     IO.binwrite(file, state.data)
#     :ok = File.close(file)

#     new_state =
#       state
#       |> Map.put(:unsaved_changes?, false)

#     {:reply, :ok, new_state}
#   end

#   def handle_cast(:close, state) do
#     if state.unsaved_changes? do
#       raise "need to be able to interact with the user here I guess..."
#     else
#       {:stop, :normal, state}
#     end
#   end



#   # def input(pid, {scenic_component_pid, input}), do: GenServer.cast(pid, {:input, {scenic_component_pid, input}})
#   # def tab_key_pressed(pid), do: GenServer.cast(pid, :tab_key_pressed)
#   # def reverse_tab(pid), do: GenServer.cast(pid, :reverse_tab)
#   # def set_mode(pid, :command), do: GenServer.cast(pid, :activate_command_mode)
#   # def save_and_close(pid), do: GenServer.cast(pid, :save_and_close)




#   # def handle_cast({:input, {scenic_component_pid, {:codepoint, {letter, _num}}}}, %{focus: :text} = state) do
#   #   state = %{state|text: state.text <> letter}
#   #   GUI.Component.Note.append_text(scenic_component_pid, :text, state)
#   #   {:noreply, state}
#   # end

#   # def handle_cast(:tab_key_pressed, %{focus: :title} = state) do
#   #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TEXT_SECTION'})
#   #   new_state = %{state|focus: :text}
#   #   {:noreply, new_state}
#   # end

#   # def handle_cast(:save_and_close, state) do
#   #   DataFile.read()
#   #     |> Map.merge(%{
#   #          state.uuid => %{
#   #            title: state.title,
#   #            text: state.text,
#   #            datetime_utc: DateTime.utc_now(),
#   #            #TODO hash entire contents
#   #            #TODO handle timezones
#   #            tags: ["note"]
#   #          },
#   #        })
#   #     |> DataFile.write()

#   #   GUI.Scene.Root.action({:active_buffer, :note, 'CLOSE_NOTE_BUFFER'})
#   #   {:noreply, state}
#   # end

#   # def handle_cast(:tab_key_pressed, %{focus: :text} = state) do
#   #   Logger.warn "Text area doesn't handle tab character just yet..."
#   #   {:noreply, state}
#   # end

#   # def handle_cast(:reverse_tab, %{focus: :text} = state) do
#   #   Logger.warn "YES we got a shift+Tab in text though" #THIS WORKS!
#   #   GUI.Scene.Root.action({:active_buffer, :note, 'MOVE_CURSOR_TO_TITLE_SECTION'})
#   #   new_state = %{state|focus: :title}
#   #   {:noreply, new_state}
#   # end

# end

defmodule Flamelex.Buffer.Utils.TextBuffer.ModifyHelper do
  use Flamelex.ProjectAliases
  alias Flamelex.Buffer.Utils.TextBufferUtils

  #TODO use ReducerBehaviour - they all need to do this, start a task under
  # the corresponding supervisor thing (micromanager pattern)

  #TODO move this under Registry.lookup(BufferRegistry, id)


  def start_modification_task(state, params) do # params e.g.
    # spin up a new process to do the handling...
    Task.Supervisor.start_child(
        find_supervisor_pid(state),  # start the task under the Task.Supervisor specific to this Buffer
            __MODULE__,
            :modify,
            [state, params]
      )
  end

  def find_supervisor_pid(%{rego_tag: rego_tag = {:buffer, _details}}) do
    ProcessRegistry.find!({:buffer, :task_supervisor, rego_tag})
  end


  # def start_modification_task(state, specifics) do
  #   #TODO start the task under the Task.Supervisor

  #   Task.Supervisor.start_child(
  #     this_buffers_corresponding_task_supervisor(),
  #   {:buffer, :task, params.source})


  #   {:ok, new_state} = modify(state, specifics)



  #   # {:buffer, :task_supervisor, params.source}
  #   # ProcessRegistry.find!(state.rego_tag)
  #   ProcessRegistry.find!(state.source)
  #   |> GenServer.cast({:update, new_state})
  # end


  # special case for the newline character
  # def modify(state, %{append: text = "\n", line: l}) when is_integer(l) do

  #   new_lines = List.insert_at(state.lines, l, %{line: l, text: text}) #TODO create new Line struct here
  #   new_data  = TextBufferUtils.join_lines_into_raw_text(new_lines)

  #   #TODO trigger re-draw

  #   {:ok, %{state|data: new_data, lines: new_lines}}
  # end

  def modify(state, params) do
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
    IO.puts "modifying..."
    :timer.sleep(3_000)
  end


end


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

#   def handle_call({:modify, {:insert, {:codepoint, {char, 0}}, cursor = {:cursor, 1}}}, _from, state) when is_bitstring(char) do

#     #TODO
#     # cursor_coords =
#     #   ProcessRegistry.find!(Cursor.rego_tag(cursor))
#     #   |> GenServer.call(:get_coords)

#     insertion_site = 3 #TODO

#     insert_text_function =
#       fn string ->
#         {before_split, after_split} = string |> String.split_at(insertion_site)
#         before_split <> char <> after_split
#       end

#     new_state =
#         state
#         |> Map.update!(:data, insert_text_function)
#         |> Map.put(:unsaved_changes?, true)

#     Flamelex.GUI.Controller.refresh(new_state)

#     {:reply, :ok, new_state}
#   end

#   def handle_call({:modify, {:insert, new_text, insertion_site}}, _from, state) when is_bitstring(new_text) and is_integer(insertion_site) do

#     insert_text_function =
#         fn string ->
#           {before_split, after_split} = string |> String.split_at(insertion_site)
#           before_split <> new_text <> after_split
#         end

#     new_state =
#         state
#         |> Map.update!(:data, insert_text_function)
#         |> Map.put(:unsaved_changes?, true)

#     Flamelex.GUI.Controller.refresh(new_state)

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

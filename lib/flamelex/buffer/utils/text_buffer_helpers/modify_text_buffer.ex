defmodule Flamelex.Buffer.Utils.TextBuffer.ModifyHelper do
  use Flamelex.ProjectAliases
  alias Flamelex.Buffer.Utils.TextBufferUtils


  def start_modification_task(state, params) do # params e.g.
    # spin up a new process to do the handling...
    Task.Supervisor.start_child(
        find_supervisor_pid(state),  # start the task under the Task.Supervisor specific to this Buffer
            __MODULE__,
            :call_modify_and_callback,
            [state, params]
      )
  end

  @doc """
  This is here so we have a library of pure functions we can call, whilst
  still having the callback logic contained within the Task.
  """
  def call_modify_and_callback(state, params) do
    {:ok, new_state} = modify(state, params)

    #TODO update GUI
    #     # Flamelex.GUI.Controller.refresh({:buffer, state.name})
#     # Flamelex.GUI.Controller.show({:buffer, filepath}) #TODO this is just a request, top show a buffer. Once I really nail the way we're linking up buffers/components, come back & fix this


  #   {:gui_component, new_state.name}
  #   |> ProcessRegistry.find!()
  #   |> GenServer.cast({:refresh, new_state})


  #   Flamelex.GUI.Controller.refresh(new_state)


    ProcessRegistry.find!(state.rego_tag)
    |> GenServer.cast({:update, new_state})

    :ok
  end

  # special case for the newline character
  def modify(state, %{append: text = "\n", line: l}) when is_integer(l) do
    IO.puts "NEWLINE SPECIAL CASE!!!"

    new_lines = List.insert_at(state.lines, l, %{line: l, text: text}) #TODO create new Line struct here
    new_data  = TextBufferUtils.join_lines_into_raw_text(new_lines)

    #TODO trigger re-draw

    {:ok, %{state|data: new_data, lines: new_lines}}
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

  def modify(%{cursors: cursors} = state, {:insert, text, %{coords: {:cursor, n}}})
    when is_list(cursors)
     and length(cursors) >= 1
      do

        %{col: c, line: l}  = Enum.at(cursors, n-1) # stupid indexing...

        IO.puts "LINE: #{inspect l}"

        new_line = state.lines
                   |> IO.inspect(label: "WERERERERERERERERER")
                   |> Enum.at(l-1-1) #TODO lol this is a mistake somehow
                   |> IO.inspect(label: "WERERERERERERERER2222222ER")
                   |> insert_text_into_line(text, c)

        new_lines = state.lines
                    |> List.replace_at(l, new_line)

        new_data  = TextBufferUtils.join_lines_into_raw_text(new_lines)

        {:ok, state
              |> Map.put(:data, new_data)
              |> Map.put(:lines, new_lines)
              |> Map.put(:unsaved_changes?, true)}
  end





  def modify(state, params) do
    IO.puts "TODO this catchall needs to be deleted.... but it's a good way of seeing tasks be spun up in the process tree..."
    IO.puts "#{inspect state, pretty: true}"
    IO.puts "#{inspect params, pretty: true}"
    :timer.seconds(30)
    IO.puts "DONE!"
  end



    #   insert_text_function =
  #       fn string ->
  #         list_of_text_lines = String.split(string, "\n")

  #         {this_line, _other_lines} = list_of_text_lines |> List.pop_at(cursor_y)

  #         {before_split, after_split} = this_line |> String.split_at(cursor_x)

  #         updated_line = before_split <> new_text <> after_split

  #         updated_list_of_text_lines = list_of_text_lines |> List.replace_at(cursor_y, updated_line)

  #         updated_list_of_text_lines |> Enum.join()
  #       end
  def insert_text_into_line(%{text: line_of_text} = line, new_text, pos)
    when is_bitstring(line_of_text)
     and is_bitstring(new_text)
    #  and pos >= 1 # characters start at 1
    #  and length(line_of_text) >= pos-1
     do

      #   insert_text_function =
      #       fn string ->
      #         {before_split, after_split} = string |> String.split_at(insertion_site)
      #         before_split <> new_text <> after_split
      #       end

    {before_split, after_split} = line_of_text |> String.split_at(pos)

    %{line|text: before_split <> new_text <> after_split}
  end




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






  defp find_supervisor_pid(%{rego_tag: rego_tag = {:buffer, _details}}) do
    ProcessRegistry.find!({:buffer, :task_supervisor, rego_tag})
  end
end

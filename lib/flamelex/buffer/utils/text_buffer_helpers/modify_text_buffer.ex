defmodule Flamelex.Buffer.Utils.TextBuffer.ModifyHelper do
  use Flamelex.ProjectAliases
  alias Flamelex.Buffer.Utils.TextBufferUtils
  alias Flamelex.Buffer.Utils.CursorMovementUtils


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
    text_buffer_pid = ProcessRegistry.find!(state.rego_tag)
    GenServer.cast(text_buffer_pid, {:state_update, new_state})
  end


  # special case for the newline character
  def modify(state, %{append: _text = "\n", line: l}) when is_integer(l) and l >= 1 do



    IO.puts "NEWLINE SPECIAL CASE!!! #{inspect l}"

    IO.inspect state.lines, label: "LINES??"

    new_lines = List.insert_at(state.lines, l-1, %{line: l, text: ""}) # put anew line containing just a blank string in
    #TODO need to bump all lines after aswell... fuck. Much smarter dont even worry about keeping a second index at this point
    new_data  = TextBufferUtils.join_lines_into_raw_text(new_lines) # then re-crunch the raw_data from the lines

    IO.puts "NEW LINES ??? #{inspect new_lines}"

    {:ok, %{state|data: new_data, lines: new_lines}}
  end

  #TODO maybe? Do we need a special case here for empty text data & pressing backspace?
  def modify(%{data: ""} = state, %{backspace: _cursor}) do
    {:ok, state}
  end

  #TODO here, I think we're trying to make text backspacable
  # def modify(state, %{backspace: %{line: l, col: c}}) do
  def modify(state, %{backspace: {:cursor, n}}) do

    %{col: c, line: l} = Enum.at(state.cursors, n-1) # stupid indexing...

    IO.puts "Applying the BACKSPACE mod..."

    # find cursor position
    %{text: line_of_text, line: ^l} = state.lines |> Enum.at(l-1)

    # delete text left of this by 1 char
    {before_cursor_text, after_and_under_cursor_text} =
              line_of_text |> String.split_at(c)
    {backspaced_text, _deleted_text} =
              before_cursor_text |> String.split_at(-1)
    full_backspaced_text =
              backspaced_text <> after_and_under_cursor_text

    new_state_lines_struct = state.lines
                             |> List.replace_at(l-1, %{line: l, text: full_backspaced_text}) #NOTE: lines start at 1, but Enum indixes start at zero

    IO.inspect new_state_lines_struct, label: "NSLS"

    new_data  = TextBufferUtils.join_lines_into_raw_text(new_state_lines_struct)

    #TODO here is where we update GUI... kinda... not perfect
    ProcessRegistry.find!({:gui_component, state.rego_tag}) #TODO this should be a GUI.Component.TextBox, not, :gui_component !!
    |> GenServer.cast({:modify, :lines, new_state_lines_struct})

    {:ok, state
          |> CursorMovementUtils.move_cursor_and_update_gui(%{cursor_num: 1, instructions: {:left, 1, :column}}) #TODO cursor 1 again
          |> Map.replace!(:data, new_data)
          |> Map.replace!(:lines, new_state_lines_struct)
          |> Map.replace!(:unsaved_changes?, true)}
  end

  # #   new_graph =
  # #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  # #     #TODO render a helper string when the buffer is empty
  # #     # case new_buf.content do
  # #     #   "" -> # render msg but keep text buffer as empty string
  # #     #     graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
  # #     #   non_blank_string ->
  # #     #     graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
  # #     # end



#   #   new_graph =
#   #     case new_state.text do
#   #       "" -> # render msg but keep text buffer as empty string
#   #         graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
#   #       non_blank_string ->
#   #         graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
#   #     end

#   #   {new_state, new_graph}
#   # end





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

        %{col: c, line: line_num} = Enum.at(cursors, n-1) # stupid indexing...
        if line_num < 1, do: raise "we are not able to process negative line numbers"
        if c < 1, do: raise "we are not able to process negative column numbers"

        new_line = state.lines
                   |> Enum.at(line_num-1) #NOTE: lines start at 1, but Enum indixes start at zero
                   |> insert_text_into_line(text, c)

        new_lines = state.lines
                    |> List.replace_at(line_num-1, new_line) #NOTE: lines start at 1, but Enum indixes start at zero

        new_data  = TextBufferUtils.join_lines_into_raw_text(new_lines)

        #TODO here is where we update GUI... kinda... not perfect
        ProcessRegistry.find!({:gui_component, state.rego_tag}) #TODO this should be a GUI.Component.TextBox, not, :gui_component !!
        |> GenServer.cast({:modify, :lines, new_lines})

        {:ok, state
              |> Map.replace!(:data, new_data)
              |> Map.replace!(:lines, new_lines)
              |> Map.replace!(:unsaved_changes?, true)}
  end

  # `insertion_site` is a count of how many characters from the start of
  # the text.
  def modify(state, {:insert, text, insertion_site})
    when is_bitstring(text)
    and is_integer(insertion_site)
      do
        {before_split, after_split} = state.data |> String.split_at(insertion_site)
        new_data = before_split <> text <> after_split

        {:ok, state
              |> Map.put(:data, new_data)
              |> Map.put(:lines, TextBufferUtils.parse_raw_text_into_lines(new_data))
              |> Map.put(:unsaved_changes?, true)}
  end




  # def modify(state, params) do
  #   IO.puts "TODO this catchall needs to be deleted.... but it's a good way of seeing tasks be spun up in the process tree..."
  #   IO.puts "#{inspect state, pretty: true}"
  #   IO.puts "#{inspect params, pretty: true}"
  #   :timer.seconds(30)
  #   IO.puts "DONE!"
  # end



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

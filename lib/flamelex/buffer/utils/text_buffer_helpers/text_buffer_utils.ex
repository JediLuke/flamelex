defmodule Flamelex.Buffer.Utils.TextBufferUtils do
  use Flamelex.ProjectAliases


  def save(%{source: {:file, filepath}} = state) do

    {:ok, file} = File.open(filepath, [:write])
    IO.binwrite(file, state.data) #TODO - maybe?
    :ok = File.close(file)

    {:ok, state |> Map.put(:unsaved_changes?, false)}
  end

  def parse_raw_text_into_lines(raw_text) do
    {lines_of_text, _final_accumulator} =
        raw_text
        |> String.split("\n") # split it up into each line based on newline char
        |> Enum.map_reduce(
                  1, # initialize accumulator to 1, so we start with line_num=1
                  fn line_of_text, line_num ->
                       {%{text: line_of_text, line: line_num}, line_num+1}
                  end)

    lines_of_text
  end

  # the opposite of parse_raw_text_into_lines/1
  def join_lines_into_raw_text(lines) do
    Enum.reduce(lines, "", fn %{text: t}, acc -> acc <> t end)
  end

  #TODO right now this has a side-effect (fire off a message) - would be
  # better if I can have it so that it doesn't have side-effects
  # (since this function just updates the state, what should really happen,
  # is that we just send the updated state to a general purpose render function)
  def move_cursor(state, %{cursor_num: n, instructions: instructions}) when is_integer(n) do
    case state.cursors |> Enum.at(n-1) do # cursors start at 1, lists do not
      nil ->
        raise "You are attempting to move a cursor (#{inspect n}), but that cursor is not registered in the buffer."
      cursor ->
        new_cursor = case {cursor, instructions} do
          {%{line: l, col: c}, {:down, x, :line}}   -> %{line: l+x, col: c} #TODO this doesn't check if we have hit the limit for number of lines
          {%{line: l, col: c}, {:up,   x, :line}}   -> %{line: l-x, col: c} #TODO this doesn't check if we have hit the limit for number of lines
          {_old_cursor,        {:goto, new_coords}} -> new_coords
        end

        # send an update request to the :gui_component (redraw)
        ProcessRegistry.find!({:cursor, n, {:gui_component, state.rego_tag}})
        |> GenServer.cast({:reposition, new_cursor}) #TODO change this to update

        # update state with the new cursor position
        new_state =
          %{state|cursors: state.cursors |> List.replace_at(n-1, new_cursor)}

        {:ok, new_state}
    end
  end

  def handle_cast({:move_cursor, %{cursor_num: n=1, goto: %{col: col, line: line}}}, state) do #TODO hard-coded as first ursor for now

    new_cursor = %{col: col, line: line}

    # update state with the new cursor position
    new_state =
      %{state|cursors: state.cursors |> List.replace_at(n-1, new_cursor)}

    # send an update request to the :gui_component (redraw)
    ProcessRegistry.find!({:cursor, n, {:gui_component, state.rego_tag}})
    |> GenServer.cast({:reposition, new_cursor})

    {:noreply, new_state}
  end
end

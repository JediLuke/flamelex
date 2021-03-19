defmodule Flamelex.Buffer.Utils.CursorMovementUtils do
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Component.TextCursor

  @doc """
  This is here so we have a library of pure functions we can call, whilst
  still having the callback logic contained within the Task.
  """
  def move_cursor_and_update_gui(%{rego_tag: tag} = state, args) do
    {:ok, new_state} = move_cursor(state, args)
    update_gui(new_state)
    #TODO need to test this actually sends back the updates we expect!
    GenServer.cast(ProcessRegistry.find!(tag), {:state_update, new_state}) #TODO kinda shitty cause we did change the GUI...
  end

  #TODO
  # maybe we don't want to do this... instead we get TextBuffer to broadcast
  # an entire-state update to the :gui_event_bus, which then triggers the change...
  # that feels like it might be neater. But for now, this gets the job done
  def update_gui(%{rego_tag: tag, cursors: _c} = state) do
    state.cursors |> Enum.each(fn new_cursor_state ->
      TextCursor.rego_tag(%{ref: {:gui_component, tag}, num: 1}) #TODO this should be a variable in new_cursor_state.num
      |> ProcessRegistry.find!()
      |> GenServer.cast({:update, new_cursor_state})
    end)
  end


  # pure-functions only below this line

  def move_cursor(buffer_state, %{cursor_num: n, instructions: {:last_col, :line, l}}) do
    # get cursor position for the last char on line l, by counting chars in that line
    %{line: ^l, text: t} = buffer_state.lines |> Enum.at(l-1)
    num_chars = String.length(t)

    move_cursor(buffer_state, %{cursor_num: n, instructions: {:goto, %{line: l, col: num_chars}}})
  end


  def move_cursor(state, %{cursor_num: n, instructions: instructions}) when is_integer(n) do
    case state.cursors |> Enum.at(n-1) do # cursors start at 1, lists do not
      nil ->
        raise "You are attempting to move a cursor (#{inspect n}), but that cursor is not registered in the buffer."
      cursor ->
        new_cursor = case {cursor, instructions} do
          {%{line: l, col: c}, {:down,  x, :line}}   -> %{line: l+x, col: c} #TODO this doesn't check if we have hit the limit for number of lines
          {%{line: l, col: c}, {:up,    x, :line}}   -> %{line: l-x, col: c} #TODO this doesn't check if we have hit the limit for number of lines
          {%{line: l, col: c}, {:right, x, :column}} -> %{line: l, col: c+x} #TODO this doesn't check if we have hit the limit for number of lines
          {%{line: l, col: c}, {:left,  x, :column}} -> %{line: l, col: c-x} #TODO this doesn't check if we have hit the limit for number of lines
          {_old_cursor,        {:goto,  new_coords}} -> new_coords
        end

        # update state with the new cursor position
        new_state = %{state|cursors: state.cursors
                                     |> List.replace_at(n-1, new_cursor)}

        #TODO in the test, assert that the cursor I am trying to move, is the one that got moved!
        {:ok, new_state}
    end
  end


  # def handle_cast({:move_cursor, %{cursor_num: n=1, goto: %{col: col, line: line}}}, state) do #TODO hard-coded as first ursor for now

  #   new_cursor = %{col: col, line: line}

  #   # update state with the new cursor position
  #   new_state =
  #     %{state|cursors: state.cursors |> List.replace_at(n-1, new_cursor)}

  #   # send an update request to the :gui_component (redraw)
  #   ProcessRegistry.find!({:cursor, n, {:gui_component, state.rego_tag}})
  #   |> GenServer.cast({:reposition, new_cursor})

  #   {:noreply, new_state}
  # end
end

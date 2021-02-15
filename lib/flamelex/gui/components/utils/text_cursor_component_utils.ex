defmodule Flamelex.GUI.Component.Utils.TextCursor do
  use Flamelex.ProjectAliases
    alias Flamelex.GUI.Component.Utils.TextBox, as: TextBoxDrawUtils

  def calc_starting_coordinates(frame) do
    # these are the original honme/base positions of the cursor - where we
    # render it, before the user has moved it at all

    # NOTES:
    # so, you would think that this lovely little equation...
    #   y_pos_of_cursor = frame.top_left.y+frame.margin.top-block_height
    # would be correct, considering Scenic renders blocks from the bottom-left for some reason..
    # however, it just looks weird! So, we move it down, a small offset

    _block_dimensions = {_w, block_height} = cursor_box_dimensions(:normal) #NOTE start in normal mode

    cursor_y_aesthetic_offset = 4

    cursor_x_pos = frame.top_left.x+frame.margin.left
    cursor_y_pos = frame.top_left.y+frame.margin.top-block_height+cursor_y_aesthetic_offset

    {cursor_x_pos, cursor_y_pos}
  end

  def switch_mode({graph, %{ref: buf_ref} = state}, new_mode) do
    block_dimensions = {_w, _h} = cursor_box_dimensions(new_mode)

    new_state =
      %{state|mode: new_mode} # the visual effect is better if you dont blink the cursor when moving it

    new_graph =
      graph
      |> Scenic.Graph.modify(
                        buf_ref,
                        &Scenic.Primitives.rectangle(&1, block_dimensions)) # resize the rectangle

    {new_graph, new_state}
  end

  def handle_blink({graph, %{ref: buf_ref} = state}) do
    new_state =
      case state.override? do
        :visible ->
          %{state|hidden?: false, override?: nil}
        :invisible ->
          %{state|hidden?: true, override?: nil}
        nil ->
          %{state|hidden?: not state.hidden?}
      end

    new_graph =
      graph
      |> Scenic.Graph.modify(
                buf_ref,
                &Scenic.Primitives.update_opts(&1,
                                      hidden: new_state.hidden?))

    {new_graph, new_state}
  end

  def reposition({graph, state}, %{line: l, col: c}) do

    {start_x, start_y} = state.original_coordinates

    new_x = start_x + (cursor_box_width()*(c-1)) #REMINDER: we need the -1 here because we starts lines & columns at 1 not zero
    new_y = start_y + (cursor_box_height()*(l-1))

    new_state =
      %{state|current_coords: {new_x, new_y}, override?: :visible} # the visual effect is better if you dont blink the cursor when moving it

    new_graph =
      graph |> modify_cursor_position(new_state)

    {new_graph, new_state}
  end

  def move_cursor({graph, state}, %{instructions: instructions}) do

    new_coords =
        state
        |> reposition_cursor(%{move: instructions})

    new_state =
        %{state|current_coords: new_coords, override?: :visible} # the visual effect is better if you dont blink the cursor when moving it

    new_graph =
        graph |> modify_cursor_position(new_state)

    {new_graph, new_state}
  end

  def cursor_box_dimensions(:normal) do
    w = cursor_box_width()
    h = cursor_box_height()
    {w, h}
  end

  def cursor_box_dimensions(:insert) do
    w = 2
    h = cursor_box_height()
    {w, h}
  end

  def cursor_box_height do
    # font = Flamelex.GUI.Fonts.primary(:font)
    # size = Flamelex.GUI.Fonts.size()
    # Flamelex.GUI.Fonts.monospace_font_height(font, size)
    Flamelex.GUI.Component.Utils.TextBox.line_height()
  end

  def cursor_box_width do
    font = Flamelex.GUI.Fonts.primary(:font)
    size = Flamelex.GUI.Fonts.size()
    Flamelex.GUI.Fonts.monospace_font_width(font, size)
  end


  # private functions


  defp reposition_cursor(%{current_coords: {old_x, old_y}}, %{move: {:down, num_lines, :line}}) do
    {old_x, old_y+num_lines*cursor_box_height()} # add y-axis, means move down the page
  end

  defp reposition_cursor(%{current_coords: {old_x, old_y}}, %{move: {:up, num_lines, :line}}) do
    {old_x, old_y-num_lines*cursor_box_height()} # subtract y-axis, means move up the page
  end

  defp reposition_cursor(%{current_coords: {old_x, old_y}}, %{move: {:left, x, :column}}) when is_integer(x) and  x >= 1 do
    {old_x-cursor_box_width()*x, old_y} # subtraction means left
  end

  defp reposition_cursor(%{current_coords: {old_x, old_y}}, %{move: {:right, x, :column}}) when is_integer(x) and x >= 1 do
    {old_x+cursor_box_width()*x, old_y} # addition means right
  end

  defp reposition_cursor(%{original_coordinates: {_x, original_y}} = state, %{move: %{last: :line, same: :column}}) do

    lines_of_text =
      Flamelex.API.Buffer.read(state.ref)
      |> TextBoxDrawUtils.split_into_a_list_of_lines_of_text_structs()

    num_lines = lines_of_text |> Kernel.length()

    {current_x, _current_y} = state.current_coords

    {current_x, original_y+num_lines*cursor_box_height()}
  end

  defp modify_cursor_position(graph, %{ref: ref} = new_state) do
    graph
    |> Scenic.Graph.modify(
              ref,
              &Scenic.Primitives.update_opts(&1,
                                    hidden?: new_state.hidden?,
                                    translate: new_state.current_coords))
  end
end

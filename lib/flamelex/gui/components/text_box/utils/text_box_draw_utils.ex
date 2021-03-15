defmodule Flamelex.GUI.Component.Utils.TextBox do
  # alias Flamelex.GUI.Structs.{Coordinates, LineOfText}
  # alias Flamelex.GUI.Structs.Frame


  #TODO move this somewhere else
  def split_into_a_list_of_lines_of_text_structs(text) do
    {lines_of_text, _final_accumulator} =
        text
        |> String.split("\n") # split it up into each line based on newline char
        |> Enum.map_reduce(1, # initialize accumulator to 1, so we start with line_num=1
                  fn line_of_text, line_num ->

                       new_line_of_text = LineOfText.new(%{
                              text: line_of_text, line_num: line_num
                            })

                       {new_line_of_text, line_num+1}
                  end)

    lines_of_text
  end

  def render_lines(graph, []) do # NOTE: empty list...
    graph
  end


  #TODO - register all the lines, a single group, with a name like `text`
  # then, we can update that text, instead of re-writing it...

  def render_lines(graph, %{frame: frame, lines: lines}) when is_list(lines) do
    {new_graph, _final_line_num} = # REMINDER: this tuple is the final accumulator, passed through by Enum.reduce/2
      lines
        |> Enum.reduce(
              {graph, 1}, # initialize the accumulator,- line_num starts at 1
              fn %{text: line_of_text}, {graph, line_num} ->
                  new_graph =
                    graph
                    |> render_single_line(%{
                          position_tuple: {line_num, frame.top_left}, #TODO should be frame.coords.top_left
                          margin: frame.margin,
                          text: line_of_text
                        })

                  #REMINDER: Enum.reduce/2 expects the function to pass through the accumulator
                  {new_graph, line_num+1}
              end)

    new_graph # we return the graph as the last thing
  end


  def render_single_line(graph, %{
    position_tuple: {line_num, frame_coords},
    margin: margin,
    text: line_of_text
  }) when is_map(margin) and is_integer(line_num) and line_num >= 1 do

    line_height          = line_height()
    line_number_y_offset = (line_num-1)*line_height #NOTE: we need the minus 1 here because lines start at 1, but we calculate the offset from 0...

    graph
    |> Scenic.Primitives.text(
         line_of_text,
         translate: {
           margin.left+frame_coords.x,
           margin.top+frame_coords.y+line_number_y_offset },
         fill: :white)
  end


  # h = Flamelex.GUI.Fonts.monospace_font_height(font, size)
  def line_height, do: 24 #TODO get 24 here from somewhere real, something to do with Fonts surely

end

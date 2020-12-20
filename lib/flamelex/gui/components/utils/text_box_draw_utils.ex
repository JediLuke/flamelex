defmodule Flamelex.GUI.Component.Utils.TextBox do
  alias Flamelex.GUI.Structs.{Coordinates, LineOfText}
  alias Flamelex.GUI.Structs.Frame


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


  def render_lines(%Scenic.Graph{} = graph, %{ lines_of_text: [] }) do #NOTE: empty list...
    graph
  end
  def render_lines(
    %Scenic.Graph{} = graph,
    %{
      lines_of_text: [ %LineOfText{} = _l | _rest] = lines,
      # top_left_corner: %Coordinates{} = coords
      frame: %Frame{top_left: %Coordinates{} = frame_top_left_coords} = frame
    })
  do
    {new_graph, _final_line_num} = # REMINDER: this is the final accumulator, passed through by Enum.reduce/2
      lines
        |> Enum.reduce(
              {graph, 0}, # initialize the accumulator, line_num starts at zero
              fn line_of_t, {graph, line_num} ->
                  new_graph =
                    graph
                    |> render_line(%{
                          position_tuple: {line_num, frame_top_left_coords},
                          margin: frame.margin,
                          text: line_of_t.text
                        })

                  #REMINDER: Enum.reduce/2 expects the function to pass through the accumulator
                  {new_graph, line_num+1}
              end)

    new_graph # we return the graph as the last thing
  end

  def line_height, do: 24 #TODO get 24 here from somewhere real, something to do with Fonts surely


  def render_line(graph, %{
    position_tuple: {line_num, frame_coords},
    margin: margin,
    text: line_of_text
  }) when is_map(margin) do

    line_height          = line_height()
    line_number_y_offset = line_num*line_height

    graph
    |> Scenic.Primitives.text(
         line_of_text,
         translate: {
           margin.left+frame_coords.x,
           margin.top+frame_coords.y+line_number_y_offset },
         fill: :white)
  end
end

defmodule Flamelex.GUI.Component.Utils.TextBox do
  alias Flamelex.GUI.Structs.{Coordinates, LineOfText}


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
          top_left_corner: %Coordinates{} = coords
        })
  do

    initial_accumulator = {
      graph,  # the initial graph
      0       # initialize the line_num to zero
    }

    {new_graph, final_line_num} = # REMINDER: this is the final accumulator, passed through by Enum.reduce/2
        lines
        |> Enum.reduce(
              initial_accumulator,
              fn line_of_t, {graph, line_num} ->

                  new_graph =
                    graph
                    |> render_line({line_num, coords}, line_of_t.text)

                  #REMINDER: Enum.reduce/2 expects the function to pass through the accumulator
                  {new_graph, line_num+1}
              end)

    IO.inspect final_line_num, label: ":::"

    # we return the graph as the last thing
    new_graph
  end


  def render_line(graph, {line_num, coords}, line_of_text) do
    line_height               = 24 #TODO get 24 here from somewhere rea
    line_number_y_offset      = line_num*line_height
    {left_margin, top_margin} = {8, 24} #TODO get margins from somewhere

    graph
    |> Scenic.Primitives.text(
         line_of_text,
         translate: {
           left_margin+coords.x,
           top_margin+coords.y+line_number_y_offset
         },
         fill:      :white)
  end
end

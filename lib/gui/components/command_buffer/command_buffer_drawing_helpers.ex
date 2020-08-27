defmodule GUI.Component.CommandBuffer.DrawingHelpers do


  @prompt_color :ghost_white
  @prompt_size 18
  @prompt_margin 12


  # @prompt_to_blinker_distance 22
  # @empty_command_buffer_text_prompt "Enter a command..."


  def draw_command_prompt(graph, %GUI.Structs.Frame{
    #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
    coordinates: %GUI.Structs.Coordinates{x: _x, y: top_left_y},
    dimensions: %GUI.Structs.Dimensions{height: height, width: _w}
  }) do
    #NOTE: The y_offset
    #      ------------
    #      From the top-left position of the box, the command prompt
    #      y-offset. (height - prompt_size) is how much bigger the
    #      buffer is than the command prompt, so it gives us the extra
    #      space - we divide this by 2 to get how much extra space we
    #      need to add, to the reference y coordinate, to center the
    #      command prompt inside the buffer
    y_offset = top_left_y + (height - @prompt_size)/2

    #NOTE: How Scenic draws triangles
    #      --------------------------
    #      Scenic uses 3 points to draw a triangle, which look like this:
    #
    #           x - point1
    #           |\
    #           | \ x - point2 (apex of triangle)
    #           | /
    #           |/
    #           x - point3
    point1 = {@prompt_margin, y_offset}
    point2 = {@prompt_margin+prompt_width(@prompt_size), y_offset+@prompt_size/2}
    point3 = {@prompt_margin, y_offset + @prompt_size}

    graph
    |> Scenic.Primitives.triangle({point1, point2, point3}, fill: @prompt_color)
  end

  defp prompt_width(prompt_size) do
    prompt_size * 0.67
  end
end

defmodule GUI.Components.CommandBuffer.DrawingFunctions do
  import Scenic.Primitives
  alias Scenic.Graph


  @margin 8               # left-hand side margin

  @prompt_margin 12
  @prompt_size 18
  @prompt_to_blinker_distance 22

  @empty_command_buffer_text_prompt "Enter a command..." #TODO move to a config file

  def echo_buffer(state) do
    state
    |> blank_graph()
    |> background(state)
    |> echo_text(state)
  end

  def empty_command_buffer(state) do
    state
    |> blank_graph()
    |> group(fn graph ->
         graph
         |> background(state, :purple)
        #  |> draw_command_prompt(state)
        #  |> add_blinking_box_cursor(state)
        #  |> draw_command_prompt_text(state)
      #  end, [
      #    id: :command_buffer,
      #   #  hidden: true
      #  ])
    end)
  end


  ## private functions
  ## -------------------------------------------------------------------


  defp blank_graph(%{opts: opts}) do
    #TODO add a check for styles
    Graph.build(
      font: opts[:styles][:font],
      font_size: opts[:styles][:font_size]
    )
  end

  defp background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}, color) when is_atom(color) do
    #TODO need width +1 here for some quirky reason of Scenic library
    graph
    |> rect({w + 1, h}, [fill: color, translate: {x, y}])
  end
  defp background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}) do
    #TODO need width +1 here for some quirky reason of Scenic library
    graph
    |> rect({w + 1, h}, [translate: {x, y}, fill: :green]) #TODO only green for dev
  end

  defp echo_text(graph, %{mode: :echo, text: t, top_left_corner: {x, y}}) do
    # text draws from bottom-left corner?? :(
    graph
    |> text(t,
         translate: {x + @margin, y + 21}, #TODO
         fill: :dark_grey
       )
  end




      # # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
      # # y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
      # y_offset = 0
      # text_centering_offset = (@text_size_px - @text_size)/2

      # # text draws from bottom-left corner?? :(
      # lower_left_corner_x = @prompt_margin - 1
      # lower_left_corner_y = y_offset + @text_size - text_centering_offset - 1


  # defp draw_status_bar(graph, data) do
  #   graph
  #   |> group(fn graph ->
  #       graph
  #       |> draw_background(data, :white_smoke)
  #       |> print_mode(data)
  #     end, [
  #       id: data.id
  #     ])
  # end


  # defp print_mode(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
  #   # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
  #   y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
  #   text_centering_offset = (@text_size_px - @text_size)/2

  #   # text draws from bottom-left corner?? :(
  #   lower_left_corner_x = @prompt_margin
  #   lower_left_corner_y = y_offset + @text_size - text_centering_offset

  #   graph
  #   |> text("COMMAND",
  #       translate: {lower_left_corner_x, lower_left_corner_y},
  #       fill: :midnight_blue)
  #   |> text("MODE",
  #       translate: {lower_left_corner_x+18, lower_left_corner_y + 18},
  #       fill: :midnight_blue)
  # end

  # defp draw_command_prompt(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
  #   x_margin = @prompt_margin
  #   y_offset = top_left_y + (height - @prompt_size)/2 # from the top-left position of the box, the command prompt y-offset. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer

  #   # cmd_prompt_coordinates =
  #   #   x - point 1
  #   #   |\
  #   #   | \ x - point 2 (apex of triangle)
  #   #   | /
  #   #   |/
  #   #   x - point

  #   cmd_prompt_coordinates =
  #     {{x_margin, y_offset}, # point 1

  #           {x_margin+@prompt_size*0.67, y_offset+@prompt_size/2}, # point 2

  #     {x_margin, y_offset + @prompt_size}} # point 3

  #   graph
  #   |> triangle(cmd_prompt_coordinates, fill: :ghost_white)
  # end

  # defp add_blinking_box_cursor(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do

  #   {_x_min, _y_min, _x_max, y_max} =
  #     GUI.FontHelpers.get_max_box_for_ibm_plex(@text_size)

  #   y_offset     = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
  #   y_box_buffer = 2 # it looks weird having box exact same size as the text
  #   x_coordinate = @prompt_margin + @prompt_to_blinker_distance
  #   y_coordinate = y_offset + y_box_buffer
  #   width        = GUI.FontHelpers.monospace_font_width(:ibm_plex, @text_size)  #TODO should probably truncate this
  #   height       = y_max + y_box_buffer #TODO should probably truncate this

  #   graph
  #   |> GUI.Component.Cursor.add_to_graph(%{
  #       top_left_corner: {x_coordinate, y_coordinate},
  #       dimensions: {width, height},
  #       parent: %{pid: self()},
  #       id: :cursor
  #     })
  # end

  # defp draw_command_prompt_text(graph, %{text: text}, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
  #   # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
  #   y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
  #   text_centering_offset = (@text_size_px - @text_size)/2

  #   # text draws from bottom-left corner?? :(
  #   lower_left_corner_x = @prompt_margin + @prompt_to_blinker_distance
  #   lower_left_corner_y = y_offset + @text_size - text_centering_offset

  #   text = if text == "", do: @empty_command_buffer_text_prompt, else: text

  #   graph
  #   |> text(text,
  #       id: :buffer_text,
  #       translate: {lower_left_corner_x, lower_left_corner_y},
  #       fill: :dark_grey)
  # end
end

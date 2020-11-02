defmodule Flamelex.GUI.Utilities.Draw do
  use Flamelex.{ProjectAliases, CustomGuards}
  # alias Flamelex.GUI.GeometryLib.Trigonometry
  # alias Flamelex.GUI.Component.CommandBuffer
  alias Flamelex.GUI.Component.MenuBar


  @ibm_plex_mono Flamelex.GUI.FontHelpers.font_hash(:ibm_plex_mono)
  @default_text_size 24


  def blank_graph(text_size \\ @default_text_size) when is_integer(text_size) do
    Scenic.Graph.build(font: @ibm_plex_mono, font_size: text_size)
  end

  @doc """
  Draw a test pattern.
  """
  def test_pattern(graph) do

    graph
    # 1st column
    |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    |> Scenic.Primitives.rect({80, 80}, fill: :green,  translate: {100, 180})
    |> Scenic.Primitives.rect({80, 80}, fill: :red,    translate: {100, 260})
    # 2nd column
    |> Scenic.Primitives.rect({80, 80}, fill: :blue,   translate: {180, 100})
    |> Scenic.Primitives.rect({80, 80}, fill: :black,  translate: {180, 180})
    |> Scenic.Primitives.rect({80, 80}, fill: :yellow, translate: {180, 260})
    # 3rd column
    |> Scenic.Primitives.rect({80, 80}, fill: :pink,   translate: {260, 100})
    |> Scenic.Primitives.rect({80, 80}, fill: :purple, translate: {260, 180})
    |> Scenic.Primitives.rect({80, 80}, fill: :brown,  translate: {260, 260})
  end

  @doc """
  Return a simple frame, doesn't contain any buffer yet.
  """
  def empty_frame(%{id: id, top_left: top_left, size: size}) do
    Frame.new(
      id: id,
      top_left_corner: top_left, #TODO make just top_left
      dimensions: size
    )
  end

  def border(graph, %Frame{} = frame) do
    border_box(graph, frame, {1, :white})
  end

  def background(%Scenic.Graph{} = graph, %Frame{} = frame, color) do
    width  = frame.dimensions.width + 1 #TODO need width +1 here for some quirky reason of Scenic library
    height = frame.dimensions.height

    graph
    |> Scenic.Primitives.rect({width, height}, fill: color, translate: {frame.coordinates.x, frame.coordinates.y})
  end

  # def triangle(graph, centroid, size) do
  #   #NOTE: How Scenic draws triangles
  #   #      --------------------------
  #   #      Scenic uses 3 points to draw a triangle, which look like this:
  #   #
  #   #           x - point1
  #   #           |\
  #   #           | \ x - point2 (apex of triangle)
  #   #           | /
  #   #           |/
  #   #           x - point3
  #   coords = Trigonometry.equilateral_triangle_coords(centroid, size)

  #   graph
  #   |> Scenic.Primitives.triangle(coords)
  # end

  @doc """
  Example:

  ```
  graph
  |> Draw.box(
        x: container_top_left_x,
        y: container_top_left_y,
        width: 10,
        height: container_height)
  ```
  """
  def box(%Scenic.Graph{} = graph, x: x, y: y, width: width, height: height) do
    graph
    |> Scenic.Primitives.rect({width, height}, fill: :white, translate: {x, y})
  end

  def border_box(%Scenic.Graph{} = graph, %Frame{} = frame) do
    width = 2
    color = :black
    border_box(graph, frame, {width, color})
  end
  def border_box(%Scenic.Graph{} = graph, %Frame{} = frame, {size, color} = stroke) when is_positive_integer(size) and is_atom(color) do

    #TODO-NOTE need + or - 1 here for some reason to do with Scenic quirks...

    x_coord = frame.coordinates.x + size - 1
    y_coord = frame.coordinates.y
    width   = frame.dimensions.width - 1
    height  = frame.dimensions.height - MenuBar.height() - size + 1

    graph
    |> Scenic.Primitives.rect({width, height}, stroke: stroke, translate: {x_coord, y_coord})
  end







  # |> Scenic.Primitives.rect({100, 100}, translate: {10, 10}, fill: :cornflower_blue, stroke: {1, :ghost_white})
  # def rectangle( #TODO this is deprecated
  #   %Scenic.Graph{} = graph,
  #   {x, y}  = _coords,
  #   [fill: c, translate: {x_translate, y_translate}] = opts)
  # when all_positive_integers(x, y, x_translate, y_translate)
  # and  is_list(opts)
  # and  is_atom(c) do
  #   coords = Coordinates.new(x: x, y: y)
  #   rectangle(graph, coords, opts)
  # end
  # def rectangle(%Scenic.Graph{} = graph, %Coordinates{} = coords, opts) when is_list(opts) do
  #   graph
  #   |> Scenic.Primitives.rect(coords, opts)
  # end

  #TODO remove this hideous function, right now it just works for rending fullscreen frames, but having card-coded coords like this is just wrong
  def text(%Scenic.Graph{} = graph, t, translate \\ {20, 20}) do
    graph
    |> Scenic.Primitives.text(t, font: @ibm_plex_mono,
               translate: translate, # text draws from bottom-left corner?? :( also, how high is it???
               font_size: 24, fill: :blue)
  end



  # def background(%Scenic.Graph{} = graph, %{top_left_corner: {x, y}, dimensions: {w, h}}, color) when is_atom(color) do
  #   #TODO need width +1 here for some quirky reason of Scenic library
  #   graph
  #   |> Scenic.Primitives.rect({w + 1, h}, [fill: color, translate: {x, y}])
  # end
  # def background(%Scenic.Graph{} = graph, %{top_left_corner: {x, y}, dimensions: {w, h}}) do
  #   #TODO need width +1 here for some quirky reason of Scenic library
  #   graph
  #   |> Scenic.Primitives.rect({w + 1, h}, [translate: {x, y}]) #TODO only green for dev
  # end
end



# defmodule Components.Utilities.CommonDrawingFunctions do
#   import Scenic.Primitives
#   alias Scenic.Graph
#   alias GUI.Structs.BufferFrame









# defmodule GUI.Component.CommandBuffer.DrawingFunctions do
#   import Scenic.Primitives
#   alias Scenic.Graph
#   alias Components.TextBox

#   def echo_buffer(state) do
#     blank_graph(state)
#     |> background(state)
#     |> echo_text(state)
#   end



#   def rectangle(%Scenic.Graph{} = graph) do
#     graph
#     |> rect({50, 50}, [fill: :red, translate: {200, 200}])
#   end


#   ## private functions
#   ## -------------------------------------------------------------------


#   defp blank_graph(%{opts: opts}) do
#     #TODO add a check for styles
#     Graph.build(
#       font: opts[:styles][:font],
#       font_size: opts[:styles][:font_size]
#     )
#   end

#   defp background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}, color) when is_atom(color) do
#     #TODO need width +1 here for some quirky reason of Scenic library
#     graph
#     |> rect({w + 1, h}, [fill: color, translate: {x, y}])
#   end
#   defp background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}) do
#     #TODO need width +1 here for some quirky reason of Scenic library
#     graph
#     |> rect({w + 1, h}, [translate: {x, y}])
#   end
#   defp background(graph, _else) do
#     graph
#   end

#   defp echo_text(graph, %{mode: :echo, text: t, top_left_corner: {x, y}}) do
#     IO.puts "ECHOING TEXT"
#     # text draws from bottom-left corner?? :(
#     graph
#     |> text(t,
#          translate: {x + @margin, y + 21}, #TODO
#          fill: :green
#        )
#   end





#       # # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
#       # # y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
#       # y_offset = 0
#       # text_centering_offset = (@text_size_px - @text_size)/2

#       # # text draws from bottom-left corner?? :(
#       # lower_left_corner_x = @prompt_margin - 1
#       # lower_left_corner_y = y_offset + @text_size - text_centering_offset - 1


#   # defp draw_status_bar(graph, data) do
#   #   graph
#   #   |> group(fn graph ->
#   #       graph
#   #       |> draw_background(data, :white_smoke)
#   #       |> print_mode(data)
#   #     end, [
#   #       id: data.id
#   #     ])
#   # end


#   # defp print_mode(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
#   #   # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
#   #   y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
#   #   text_centering_offset = (@text_size_px - @text_size)/2

#   #   # text draws from bottom-left corner?? :(
#   #   lower_left_corner_x = @prompt_margin
#   #   lower_left_corner_y = y_offset + @text_size - text_centering_offset

#   #   graph
#   #   |> text("COMMAND",
#   #       translate: {lower_left_corner_x, lower_left_corner_y},
#   #       fill: :midnight_blue)
#   #   |> text("MODE",
#   #       translate: {lower_left_corner_x+18, lower_left_corner_y + 18},
#   #       fill: :midnight_blue)
#   # end



#   # defp add_blinking_box_cursor(graph, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do

#   #   {_x_min, _y_min, _x_max, y_max} =
#   #     GUI.FontHelpers.get_max_box_for_ibm_plex(@text_size)

#   #   y_offset     = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
#   #   y_box_buffer = 2 # it looks weird having box exact same size as the text
#   #   x_coordinate = @prompt_margin + @prompt_to_blinker_distance
#   #   y_coordinate = y_offset + y_box_buffer
#   #   width        = GUI.FontHelpers.monospace_font_width(:ibm_plex, @text_size)  #TODO should probably truncate this
#   #   height       = y_max + y_box_buffer #TODO should probably truncate this

#   #   graph
#   #   |> GUI.Component.Cursor.add_to_graph(%{
#   #       top_left_corner: {x_coordinate, y_coordinate},
#   #       dimensions: {width, height},
#   #       parent: %{pid: self()},
#   #       id: :cursor
#   #     })
#   # end

#   # defp draw_command_prompt_text(graph, %{text: text}, %{top_left_corner: {_x, top_left_y}, dimensions: {_w, height}}) do
#   #   # text size != text size in pixels. We get the difference between these 2, in pixels, and halve it, to get an offset we can use to center this text inside the command buffer
#   #   y_offset = top_left_y + (height - @prompt_size)/2 # y is the reference coord, the offset from the top of the screen, where the command buffer gets drawn. (height - prompt_size) is how much bigger the buffer is than the command prompt, so it gives us the extra space - we divide this by 2 to get how much extra space we need to add, to the reference y coordinate, to center the command prompt inside the buffer
#   #   text_centering_offset = (@text_size_px - @text_size)/2

#   #   # text draws from bottom-left corner?? :(
#   #   lower_left_corner_x = @prompt_margin + @prompt_to_blinker_distance
#   #   lower_left_corner_y = y_offset + @text_size - text_centering_offset

#   #   text = if text == "", do: @empty_command_buffer_text_prompt, else: text

#   #   graph
#   #   |> text(text,
#   #       id: :buffer_text,
#   #       translate: {lower_left_corner_x, lower_left_corner_y},
#   #       fill: :dark_grey)
#   # end
# end

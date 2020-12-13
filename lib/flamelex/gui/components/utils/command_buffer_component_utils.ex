defmodule Flamelex.GUI.Component.CommandBuffer.DrawingHelpers do
  use Flamelex.ProjectAliases


  @prompt_color :ghost_white
  @prompt_size 18
  @prompt_margin 12

  @font_size Flamelex.GUI.Fonts.size()
  # @cursor_width GUI.FontHelpers.monospace_font_width(:ibm_plex, @font_size) #TODO get this properly
  @cursor_width 16

  @text_field_left_margin 2 # distance between the left-hand side of the text field box, and the start of the actual text. We want a little margin here for aesthetics
  # @prompt_to_blinker_distance 22
  # @empty_command_buffer_text_prompt "Enter a command..."


  def draw_command_prompt(graph, %Frame{
    #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
    top_left: %Coordinates{x: _top_left_x, y: top_left_y},
    dimensions: %Dimensions{height: height, width: _width}
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

  def calc_textbox_frame(_buffer_frame = %Frame{
    #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
    top_left: %Coordinates{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
    dimensions: %Dimensions{height: cmd_buf_height, width: cmd_buf_width}
  }) do
    total_prompt_width = prompt_width(@prompt_size) + (2*@prompt_margin)

    textbox_coordinates = {
      # this is the x coord for the top-left corner of the Textbox - take the CommandBuffer top_left_x and add some margin
      cmd_buf_top_left_x + total_prompt_width,
      # this is the y coord for the top-left corner of the Textbox - plus 5 to move the box down, because remember we reference from top-left corner
      cmd_buf_top_left_y + 5
    }

    textbox_width      = cmd_buf_width - total_prompt_width - @prompt_margin
    textbox_dimensions = {textbox_width, cmd_buf_height - 10}

    textbox_frame =
      Frame.new(
        top_left:     textbox_coordinates |> Coordinates.new(),
        dimensions:   textbox_dimensions  |> Dimensions.new())

    # return
    textbox_frame
  end

  def draw_input_textbox(graph, %Frame{} = textbox_frame) do
    graph
    |> Draw.border_box(textbox_frame)
  end

  def draw_cursor(
        graph,
        %Frame{
           top_left:   %Coordinates{x: container_top_left_x, y: container_top_left_y},
           dimensions: %Dimensions{height: container_height, width: _container_width}
        },
        id: cursor_component_id)
  do

    cursor_frame = Frame.new(
      top_left:   {container_top_left_x, container_top_left_y},
      dimensions: {@cursor_width, container_height})

    graph
    |> GUI.Component.Cursor.add_to_graph(cursor_frame)
  end

  def draw_text_field(
        graph,
        content,
        %Frame{
           top_left:    %Coordinates{x: container_top_left_x, y: container_top_left_y},
           dimensions:  %Dimensions{height: container_height, width: _container_width}
        },
        id: text_field_id)
  do

    graph
    |> Scenic.Primitives.text(
         content,
         id:        text_field_id,
         translate: # {x_coord, y_coord}
                    {container_top_left_x + @text_field_left_margin,
                     container_top_left_y + (container_height-4)}, # text draws from bottom-left corner?? :( also, how high is it??? #TODO
         font_size: @font_size,
         fill:      :white)

  end

  defp prompt_width(prompt_size) do
    prompt_size * 0.67
  end
end




# defmodule Flamelex.GUI.Utilities.Drawing.CommandBufferDrawingLib do
#   use Flamelex.ProjectAliases

#   def frame(%Dimensions{} = viewport, name \\ "CommandBuffer") do
#     Frame.new(
#       name:     name,
#       top_left: {0, 0},
#       size:     {viewport.width, Flamelex.GUI.Component.MenuBar.height()})
#   end
# end









# defmodule Flamelex.GUI.Component.CommandBuffer.DrawingHelpers do
#   use Flamelex.ProjectAliases


#   @prompt_color :ghost_white
#   @prompt_size 18
#   @prompt_margin 12

#   @font_size Flamelex.GUI.Fonts.size()
#   # @cursor_width GUI.FontHelpers.monospace_font_width(:ibm_plex, @font_size) #TODO get this properly
#   @cursor_width 16

#   @text_field_left_margin 2 # distance between the left-hand side of the text field box, and the start of the actual text. We want a little margin here for aesthetics
#   # @prompt_to_blinker_distance 22
#   # @empty_command_buffer_text_prompt "Enter a command..."


#   def draw_command_prompt(graph, %Frame{
#     #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
#     coordinates: %Coordinates{x: _top_left_x, y: top_left_y},
#     dimensions: %Dimensions{height: height, width: _width}
#   }) do
#     #NOTE: The y_offset
#     #      ------------
#     #      From the top-left position of the box, the command prompt
#     #      y-offset. (height - prompt_size) is how much bigger the
#     #      buffer is than the command prompt, so it gives us the extra
#     #      space - we divide this by 2 to get how much extra space we
#     #      need to add, to the reference y coordinate, to center the
#     #      command prompt inside the buffer
#     y_offset = top_left_y + (height - @prompt_size)/2

#     #NOTE: How Scenic draws triangles
#     #      --------------------------
#     #      Scenic uses 3 points to draw a triangle, which look like this:
#     #
#     #           x - point1
#     #           |\
#     #           | \ x - point2 (apex of triangle)
#     #           | /
#     #           |/
#     #           x - point3
#     point1 = {@prompt_margin, y_offset}
#     point2 = {@prompt_margin+prompt_width(@prompt_size), y_offset+@prompt_size/2}
#     point3 = {@prompt_margin, y_offset + @prompt_size}

#     graph
#     |> Scenic.Primitives.triangle({point1, point2, point3}, fill: @prompt_color)
#   end

#   def calc_textbox_frame(_buffer_frame = %Frame{
#     #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
#     coordinates: %Coordinates{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
#     dimensions: %Dimensions{height: cmd_buf_height, width: cmd_buf_width}
#   }) do
#     total_prompt_width = prompt_width(@prompt_size) + (2*@prompt_margin)

#     textbox_coordinates = {
#       # this is the x coord for the top-left corner of the Textbox - take the CommandBuffer top_left_x and add some margin
#       cmd_buf_top_left_x + total_prompt_width,
#       # this is the y coord for the top-left corner of the Textbox - plus 5 to move the box down, because remember we reference from top-left corner
#       cmd_buf_top_left_y + 5
#     }

#     textbox_width      = cmd_buf_width - total_prompt_width - @prompt_margin
#     textbox_dimensions = {textbox_width, cmd_buf_height - 10}

#     textbox_frame =
#       Frame.new(
#         top_left_corner: textbox_coordinates |> Coordinates.new(),
#         dimensions:      textbox_dimensions  |> Dimensions.new())

#     # return
#     textbox_frame
#   end

#   def draw_input_textbox(graph, %Frame{} = textbox_frame) do
#     graph
#     |> Draw.border_box(textbox_frame)
#   end

#   def draw_cursor(
#         graph,
#         %Frame{
#            coordinates: %Coordinates{x: container_top_left_x, y: container_top_left_y},
#            dimensions:  %Dimensions{height: container_height, width: _container_width}
#         },
#         id: cursor_component_id)
#   do

#     cursor_frame = Frame.new(
#       id:              cursor_component_id,
#       top_left_corner: {container_top_left_x, container_top_left_y},
#       dimensions:      {@cursor_width, container_height})

#     graph
#     |> GUI.Component.Cursor.add_to_graph(cursor_frame)
#   end

#   def draw_text_field(
#         graph,
#         content,
#         %Frame{
#            coordinates: %Coordinates{x: container_top_left_x, y: container_top_left_y},
#            dimensions:  %Dimensions{height: container_height, width: _container_width}
#         },
#         id: text_field_id)
#   do

#     graph
#     |> Scenic.Primitives.text(
#          content,
#          id:        text_field_id,
#          translate: # {x_coord, y_coord}
#                     {container_top_left_x + @text_field_left_margin,
#                      container_top_left_y + (container_height-4)}, # text draws from bottom-left corner?? :( also, how high is it??? #TODO
#          font_size: @font_size,
#          fill:      :white)

#   end

#   defp prompt_width(prompt_size) do
#     prompt_size * 0.67
#   end
# end







# defmodule Flamelex.GUI.Component.CommandBuffer.Reducer do
#   @moduledoc """
#   This module contains reducer functions - they take in a graph, & an
#   'action' (usually a string, sometimed with some params) and return a
#   mutated state and/or graph.
#   """
#   alias Scenic.Graph
#   alias Flamelex.GUI.Component.CommandBuffer.DrawingHelpers
#   import Scenic.Primitives
#   require Logger
#   use Flamelex.ProjectAliases


#   @component_id :command_buffer

#   @cursor_component_id {@component_id, :cursor, 1}
#   @text_field_id {@component_id, :text_field}

#   @command_mode_background_color :cornflower_blue

#   def initialize(%Frame{} = frame) do
#     # the textbox is internal to the command buffer, but we need the
#     # coordinates of it in a few places, so we pre-calculate it here
#     textbox_frame =
#       %Frame{} = DrawingHelpers.calc_textbox_frame(frame)

#     Draw.blank_graph()
#     |> Scenic.Primitives.group(fn graph ->
#          graph
#          |> Draw.background(frame, @command_mode_background_color)
#          |> DrawingHelpers.draw_command_prompt(frame)
#          |> DrawingHelpers.draw_input_textbox(textbox_frame)
#          |> DrawingHelpers.draw_cursor(textbox_frame, id: @cursor_component_id)
#          |> DrawingHelpers.draw_text_field("", textbox_frame, id: @text_field_id) #NOTE: Start with an empty string
#     end, [
#       id: @component_id,
#       hidden: true
#     ])
#   end

#   def process({_state, graph}, :show) do
#     new_graph =
#       graph
#       |> Graph.modify(@component_id, &update_opts(&1, hidden: false))

#     {:update_graph, new_graph}
#   end

#   def process({_state, graph}, :hide) do
#     new_graph =
#       graph
#       |> Graph.modify(@component_id, &update_opts(&1, hidden: true))

#   {:update_graph, new_graph}
# end

#   # def process({%{mode: :command} = state, _graph}, 'de_activate_command_buffer') do
#   #   new_state =
#   #     state
#   #     |> Map.replace!(:mode, :echo)
#   #     |> Map.replace!(:text, "Left `command` mode.")

#   #   new_graph =
#   #     Draw.echo_buffer(new_state)

#   #   {new_state, new_graph}
#   # end
#   def process({_state, graph}, :hide_command_buffer) do
#     new_graph =
#       graph
#       |> Graph.modify(@component_id, &update_opts(&1, hidden: true))

#     {:update_graph, new_graph}
#   end

#   def process({_state, _graph}, :move_cursor) do
#     @cursor_component_id |> GUI.Component.Cursor.move(:right)
#     :ignore_action #TODO better name would be "no update to this processes state"
#   end

#   def process({_state, _graph}, :reset_cursor) do
#     @cursor_component_id
#     |> GUI.Component.Cursor.action(:reset_position)

#     :ignore_action
#   end


#   # def process({state, graph}, {'ENTER_CHARACTER', {:codepoint, {letter, x}}}) when x in [0, 1] do # need the check on x because lower and uppercase letters have a different number here for some reason
#   def process({state, graph}, {:update_content, content}) when is_binary(content) do
#     new_graph =
#       graph |> Graph.modify(@text_field_id, &text(&1, content))

#     {:update_graph, new_graph}
#   end


#   # def process({%{text: ""} = state, _graph}, 'COMMAND_BUFFER_BACKSPACE') do
#   #   state
#   # end
#   # def process({state, graph}, 'COMMAND_BUFFER_BACKSPACE') do
#   #   {backspaced_buffer_text, _last_letter} = state.text |> String.split_at(-1)

#   #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
#   #   GenServer.cast(pid, {:action, 'MOVE_LEFT_ONE_COLUMN'})

#   #   new_state = state |> Map.replace!(:text, backspaced_buffer_text)

#   #   new_graph =
#   #     case new_state.text do
#   #       "" -> # render msg but keep text buffer as empty string
#   #         graph |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))
#   #       non_blank_string ->
#   #         graph |> Graph.modify(:buffer_text, &text(&1, non_blank_string))
#   #     end

#   #   {new_state, new_graph}
#   # end


#   # def process({state, graph}, 'CLEAR_BUFFER_TEXT') do
#   #   new_state = state |> Map.replace!(:text, "")

#   #   new_graph =
#   #     graph
#   #     |> Graph.modify(:buffer_text, &text(&1, @empty_command_buffer_text_prompt, fill: :dark_grey))

#   #   {:cursor, pid} = state.component_ref |> hd #TODO, eventually we'll have more componenst
#   #   GenServer.cast(pid, {:action, 'RESET_POSITION'})

#   #   {new_state, new_graph}
#   # end

#   # def process({state, graph}, 'PROCESS_COMMAND_BUFFER_TEXT_AS_COMMAND') do
#   #   Franklin.Commander.process(state.text)
#   #   GUI.Scene.Root.action('CLEAR_AND_CLOSE_COMMAND_BUFFER')
#   #   {state, graph}
#   # end

#   # #NOTE: This must go on the bottom, as it's the catch-all...
#   # def process({state, _graph}, unknown_action) do
#   #   IO.puts "SHOW?????"
#   #   Logger.error "#{__MODULE__} received unknown state/action combination: action: #{inspect unknown_action}, state: #{inspect state}"
#   #   :ignore_action
#   # end
# end

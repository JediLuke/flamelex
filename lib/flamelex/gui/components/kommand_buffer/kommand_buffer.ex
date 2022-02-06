defmodule Flamelex.GUI.KommandBuffer do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @height 50 #TODO

    def validate(%{viewport: %Scenic.ViewPort{size: {vp_width, vp_height}}} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"

        frame = Frame.new(
            pin:  {0, vp_height - @height},
            size: {vp_width, @height})

        {:ok, data |> Map.merge(%{frame: frame})}
    end

    def init(scene, args, opts) do

        init_state = %{
            hidden?: true
        }

        init_graph = render(args.frame, init_state)

        init_scene = scene
        |> assign(state: init_state)
        |> assign(frame: args.frame)
        |> assign(graph: init_graph)
        |> push_graph(init_graph)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        {:ok, init_scene}
    end

    def handle_info({:radix_state_change, %{kommander: new_state}}, %{assigns: %{state: current_state}} = scene)
    when new_state != current_state do
        Logger.debug "#{__MODULE__} updating..."

        new_graph = render(scene.assigns.frame, new_state)

        new_scene = scene
        |> assign(graph: new_graph)
        |> assign(state: new_state)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    #NOTE: If `state` binds on here, then both variables are the same, no state-change occured and we can ignore this update
    def handle_info({:radix_state_change, %{kommander: state}}, %{assigns: %{state: state}} = scene) do
        IO.puts "NO CHANGESSS"
        {:noreply, scene}
    end


    def render(frame, state) do
        IO.inspect state
        Scenic.Graph.build()
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> Draw.background(frame, :cornflower_blue)
            |> draw_command_prompt(frame)
            |> draw_textbox(frame)
            #  |> DrawingHelpers.draw_input_textbox(textbox_frame)
            #  |> DrawingHelpers.draw_cursor(textbox_frame, id: cursor_component_id)
            #  |> DrawingHelpers.draw_text_field("", textbox_frame, id: text_field_id) #NOTE: Start with an empty string
        end, [
            id: :kommander,
            hidden: state.hidden?
        ])
    end

    @prompt_color :ghost_white
    @prompt_size 18
    @prompt_margin 12
    def draw_command_prompt(graph, %Frame{
      #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
      top_left: %{x: _top_left_x, y: top_left_y},
      dimensions: %{height: height, width: _width}
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

    def draw_textbox(graph, %Frame{} = outer_frame) do
        # text_field_id                 = {@component_id, :text_field}
    
        #TODO here we want our own TextPad component eventually
        graph
        |> Scenic.Components.text_field("test", id: :search_field, translate: {5,5})
        # |> Flamelex.GUI.Component.TextBox.add_to_graph(%{
        #      ref: {KommandBufferGUI, TextBox},
        #      frame: calc_textbox_frame(outer_frame),
        #      border: {:solid, 1, :px},
        #      lines: [%{line: 1, text: ""}],
        #      draw_footer?: false,
        #      mode: :insert
        # })
      end
    
    
      # figure out the size of the text box
      def calc_textbox_frame(_buffer_frame = %Frame{
        #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
        top_left: %{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
        dimensions: %{height: cmd_buf_height, width: cmd_buf_width}
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
            top_left:   textbox_coordinates |> Coordinates.new(),
            dimensions: textbox_dimensions  |> Dimensions.new())
    
        textbox_frame
      end
    
      def prompt_width(prompt_size) do
        prompt_size * 0.67
      end
end
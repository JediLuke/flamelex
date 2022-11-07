defmodule Flamelex.GUI.Component.Kommander do
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger


   @prompt %{
      color: :ghost_white,
      size: 18,
      margin: 12
   }


   def validate(%{frame: %Frame{} = _f, radix_state: _radix_state} = data) do
      #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end

   def init(scene, args, opts) do

      init_state = args.radix_state.kommander

      init_graph =
         render(args.frame, init_state)

      init_scene = scene
         |> assign(state: init_state)
         |> assign(frame: args.frame)
         |> assign(graph: init_graph)
         |> push_graph(init_graph)

      Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

      {:ok, init_scene}
   end

   # NOTE - in this pattern-match, note that `hidden?` is used twice, so we match here if the values are the same in both places, i.e. the status hasn't changed
   def handle_info({:radix_state_change, %{kommander: kommander_state}}, %{assigns: %{state: kommander_state}} = scene) do
      {:noreply, scene}
   end

   # If we hide/show the Kommander, handle it here
   def handle_info({:radix_state_change, %{kommander: kommander_state = %{hidden?: now_hidden?}}}, %{assigns: %{state: %{hidden?: current_hidden_status?}}} = scene) when now_hidden? != current_hidden_status? do
      new_graph =
         scene.assigns.graph
         |> Scenic.Graph.modify(:kommander, &Scenic.Primitives.update_opts(&1, hidden: now_hidden?))

      new_scene = scene
         |> assign(state: %{kommander_state | hidden?: now_hidden?})
         |> assign(graph: new_graph)
         |> push_graph(new_graph)

      {:noreply, new_scene}
   end

   def handle_info({:radix_state_change, %{kommander: %{buffer: k_buf} = kommander_state}}, scene) do
      {:ok, [pid]} = child(scene, {:text_pad, Kommander})
      GenServer.cast(pid, {:redraw, k_buf})
      {:noreply, scene |> assign(state: %{kommander_state|buffer: k_buf})}
   end

   def handle_cast({:scroll_limits, _new_scroll_state}, scene) do
      IO.puts "Kommander ignoring scroll limits update..."
      {:noreply, scene}
    end

   def render(frame, state) do
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
         graph
         |> ScenicWidgets.FrameBox.draw(frame, %{color: :rebecca_purple})
         |> draw_command_prompt(frame)
         |> draw_textbox(state, frame)
      end, [
          id: :kommander,
          hidden: state.hidden?
      ])
   end

   def draw_command_prompt(graph, %Frame{
      #NOTE: These are the coords/dimens for the whole CommandBuffer Frame
      coords: %{x: _top_left_x, y: top_left_y},
      dimens: %{height: height, width: _width}
   }) do
      #NOTE: The y_offset
      #      ------------
      #      From the top-left position of the box, the command prompt
      #      y-offset. (height - prompt.size) is how much bigger the
      #      buffer is than the command prompt, so it gives us the extra
      #      space - we divide this by 2 to get how much extra space we
      #      need to add, to the reference y coordinate, to center the
      #      command prompt inside the buffer
      y_offset = top_left_y + (height - @prompt.size)/2

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
      point1 = {@prompt.margin, y_offset}
      point2 = {@prompt.margin+prompt_width(@prompt.size), y_offset+@prompt.size/2}
      point3 = {@prompt.margin, y_offset + @prompt.size}

      graph
      |> Scenic.Primitives.triangle({point1, point2, point3}, fill: @prompt.color)
   end

   def draw_textbox(graph, %{buffer: k_buf} = _state, %Frame{} = outer_frame) do
      textbox_frame = calc_textbox_frame(outer_frame)

      graph
      |> ScenicWidgets.FrameBox.draw(textbox_frame, %{border: :black})
      #TODO here is where we call it... need to add text rendering using TextPad, and also accept input when kommander is visible
      |> ScenicWidgets.TextPad.add_to_graph(%{
         frame: textbox_frame,
         state: ScenicWidgets.TextPad.new(%{buffer: k_buf, margin: %{left: 4, top: 3, bottom: 0, right: 2}})
      }, id: {:text_pad, Kommander})
   end

   # figure out the size of the text box
   def calc_textbox_frame(%Frame{ # these are the coords/dimens for the whole CommandBuffer Frame
      coords: %{x: cmd_buf_top_left_x, y: cmd_buf_top_left_y},
      dimens: %{height: cmd_buf_height, width: cmd_buf_width}
   }) do
      total_prompt_width = prompt_width(@prompt.size) + (2*@prompt.margin)

      textbox_coords = {
         # this is the x coord for the top-left corner of the Textbox - take the CommandBuffer top_left_x and add some margin
         cmd_buf_top_left_x + total_prompt_width,
         # this is the y coord for the top-left corner of the Textbox - plus 5 to move the box down, because remember we reference from top-left corner
         cmd_buf_top_left_y + 5
      }

      textbox_width = cmd_buf_width - total_prompt_width - @prompt.margin
      textbox_dimens = {textbox_width, cmd_buf_height - 10}

      Frame.new(
         pin: textbox_coords,
         size: textbox_dimens
      )
   end

   def prompt_width(prompt_size) do
      prompt_size * 0.67
   end
end
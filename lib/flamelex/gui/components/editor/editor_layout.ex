defmodule Flamelex.GUI.Editor.Layout do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger


    #TODO the editor layour itself shouldn't need a buffer to render else what happens if we close it??
    def validate(%{buffer_id: {:buffer, _id}, frame: %Frame{} = _fr, font: _fnt, state: _s} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."
    
        # #NOTE: This component doesn't need to subscribe to RadixState changes

        # #TODO here - use a WindowArrangement of {:columns, [1,2,1]}
        # init_graph = Scenic.Graph.build()
        # #TODO make this a ScenicWidgets.ExpandableNavBar
        # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: left_quadrant(args.frame), color: :alice_blue})
        # |> Memex.StoryRiver.add_to_graph(%{
        #         frame: mid_section(args.frame),
        #         state: args.state.story_river})
        # |> Memex.SideBar.add_to_graph(%{
        #         frame: right_quadrant(args.frame),
        #         state: args.state.sidebar})

        #TODO here need to get all the buffer details, probably from radix_state??
        init_graph = Scenic.Graph.build()
        |> Scenic.Primitives.rect(args.frame.size, translate: args.frame.pin, fill: :purple)
        |> ScenicWidgets.TextPad.add_to_graph(%{
            id: args.buffer_id,
            #TODO args.frame?
            frame: Frame.new(
                pin: {200, 225},
                size: {500, 500}),
            text: args.state.data,
            mode: args.state.mode,
            format_opts: %{
                alignment: :left,
                wrap_opts: :no_wrap,
                scroll_opts: :all_directions,
                show_line_num?: true
            },
            font: args.font |> Map.merge(%{size: 24})
        })

        new_scene = init_scene
        |> assign(buffer_id: args.buffer_id)
        |> assign(graph: init_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(init_graph)

        # cast_children(scene, :start_caret)
        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)
  
        {:ok, new_scene}
    end

    def calc_body_frame(hypercard_frame) do
		#REMINDER: Because we render this from within the group (which is
		#		   already getting translated, we only need be concerned
		#		   here with the _relative_ offset from the group. Or
		#		   in other words, this is all referenced off the top-left
		#		   corner of the HyperCard, not the top-left corner
		#		   of the screen.
		Frame.new(pin: {200, 225},
			      size: {500, 500})
	end

    # def left_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
    #     Frame.new(top_left: {x, y}, dimensions: {w/4, h})
    # end

    # def mid_section(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
    #     one_quarter_page_width = w/4
    #     Frame.new(top_left: {x+one_quarter_page_width, y}, dimensions: {w/2, h})
    # end

    # def right_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
    #     Frame.new(top_left: {x+((3/4)*w), y}, dimensions: {w/4, h})
    # end

    # def handle_info({:radix_state_change, %{kommander: new_state}}, %{assigns: %{state: current_state}} = scene)
    # when new_state != current_state do

    # def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do

    #     this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
    #     [{^this_layer, radix_layer_graph}] =
    #         layer_list |> Enum.filter(fn {layer, graph} -> layer == scene.assigns.id end)
    
    #     if scene.assigns.graph != radix_layer_graph do
    #         Logger.debug "#{__MODULE__} Layer_ #{inspect scene.assigns.id} changed, re-drawing the RootScene..."
            
    #         new_scene = scene
    #         |> assign(graph: radix_layer_graph)
    #         |> push_graph(radix_layer_graph)
    
    #         {:noreply, new_scene}
    #     else
    #         Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
    #         {:noreply, scene}
    #     end
    # end

    def handle_info({:radix_state_change, %{editor: %{buffers: []}}}, scene) do
        #TODO do a better job here lol
        # new_state = 

        new_graph = Scenic.Graph.build()

        new_scene = scene
        |> assign(buffer_id: nil)
        |> assign(graph: new_graph)
        # |> assign(frame: args.frame)
        # |> assign(state: args.state)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    def handle_info({:radix_state_change, %{editor: %{buffers: buffers}}}, %{assigns: %{buffer_id: this_buf_id}} = scene) do
        this_buf = buffers |> Enum.find(& &1.id == this_buf_id)
        if this_buf.graph != scene.assigns.graph do
            Logger.debug "Buffer `#{inspect this_buf.id}` has changed, updating it."
            
            IO.inspect this_buf, label: "THIS BUGF"

            new_scene = scene
            |> assign(graph: this_buf.graph)
            |> assign(state: this_buf)
            |> push_graph(this_buf.graph)

            {:noreply, new_scene}
        else
            Logger.debug "Buffer `#{inspect this_buf.id}` not updating, nothing has changed..."
            {:noreply, scene}
        end
    end

end
defmodule Flamelex.GUI.Editor.Layout do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    # alias Flamelex.GUI.Component.Memex

    def validate(%{frame: %Frame{} = _f} = data) do
        #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, args, opts) do
        # #Logger.debug "#{__MODULE__} initializing..."
    
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


        #TODO here we need to render a ScenicWidgets.TextPad

        init_graph = Scenic.Graph.build()
        |> Scenic.Primitives.rect(args.frame.size, translate: args.frame.pin, fill: :purple)

        new_scene = init_scene
        |> assign(graph: init_graph)
        # |> assign(frame: args.frame)
        # |> assign(state: args.state)
        |> push_graph(init_graph)

        # # cast_children(scene, :start_caret)
  
        {:ok, new_scene}
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
end
defmodule Flamelex.GUI.Memex.Layout do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    alias Flamelex.GUI.Component.Memex

    def validate(%{frame: %Frame{} = _f, state:  _memex} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."
    
        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        init_graph = Scenic.Graph.build()
        # |> Memex.CollectionsPane.add_to_graph(%{frame: left_quadrant(params.frame)})
        # |> Memex.StoryRiver.add_to_graph(%{frame: mid_section(params.frame)})
        # |> Memex.SideBar.add_to_graph(%{frame: right_quadrant(params.frame)})
        |> Memex.SideBar.add_to_graph(%{
                frame: right_quadrant(args.frame),
                state: args.state.sidebar
            })
        # |> Memex.SecondSideBar.add_to_graph(%{frame: right_quadrant(params.frame)})

        #TODO here - use a WindowArrangement of {:columns, [1,2,1]}

        new_scene = init_scene
        |> assign(graph: init_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(init_graph)
  
        {:ok, new_scene}
    end

    def handle_info({:radix_state_change, _new_radix_state}, scene) do
        #NOTE: I don't think the Layout component really needs to know
        #      about state changes, maybe changes to viewport??
        #Logger.debug "#{__MODULE__} ignoring a RadixState change..."
        {:noreply, scene}
    end


    def left_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
        Frame.new(top_left: {x, y}, dimensions: {w/4, h})
    end

    def mid_section(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
        one_quarter_page_width = w/4
        Frame.new(top_left: {x+one_quarter_page_width, y}, dimensions: {w/2, h})
    end

    def right_quadrant(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}} = frame) do
        Frame.new(top_left: {x+((3/4)*w), y}, dimensions: {w/4, h})
    end
end
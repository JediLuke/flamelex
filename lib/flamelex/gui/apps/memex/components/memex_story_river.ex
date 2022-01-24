defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end


    def init(scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."

        new_graph = Scenic.Graph.build()
        |> render_tidbits(args)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        new_scene = scene
        |> assign(graph: new_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(new_graph)

        {:ok, new_scene}
    end

    def handle_info({:radix_state_change, %{memex: %{story_river: new_story_river_state}}}, %{assigns: %{state: current_state}} = scene)
        when new_story_river_state != current_state do
            Logger.debug "#{__MODULE__} updating StoryRiver..."

            new_graph = Scenic.Graph.build()
            #|> ScenicWidgets.FrameBox.add_to_graph(%{frame: scene.assigns.frame, color: :pink})
            |> render_tidbits(%{state: new_story_river_state, frame: scene.assigns.frame})

            new_scene = scene
            |> assign(graph: new_graph)
            |> assign(state: new_story_river_state)
            |> push_graph(new_graph)
    
            {:noreply, new_scene}
    end

    #NOTE: If `story_river_state` binds on both variables here, then they are the same, no state-change occured and we can ignore this update
    def handle_info({:radix_state_change, %{memex: %{story_river: story_river_state}}}, %{assigns: %{state: story_river_state}} = scene) do
        {:noreply, scene}
    end

    def render_tidbits(graph, %{state: %{open_tidbits: []}} = _story_river_state) do
        graph |> Scenic.Graph.delete(__MODULE__)
    end

    def render_tidbits(graph, %{state: %{open_tidbits: [%Memelex.TidBit{} = tidbit], scroll: scroll}, frame: frame}) do
        new_graph = graph
        |> Scenic.Graph.delete(__MODULE__)
        |> Scenic.Primitives.group(fn graph ->
                graph
                #TODO here is where new args will go
                # |> ScenicWidgets.HyperCard.add_to_graph(%{
                |> Flamelex.GUI.Component.Memex.HyperCard.add_to_graph(%{
                        id: tidbit.uuid,
                        frame: hypercard_frame(frame),
                        state: tidbit
                })
            end, [
                id: __MODULE__,
                translate: scroll
            ])
    end





        #           |> LayoutList.add_to_graph(%{
#                 id: :story_layout_list, #TODO lol
#                 frame: params.frame,
#                 # components: calc_component_list(open_tidbits)
#                 components: [],
#                     # %{module: HyperCard, params: hd(open_tidbits), opts: []} #TODO?
#                 layout: :flex_grow,
#                 scroll: true
#           }, id: :story_layout_list) #TODO lol





    # def hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do
    def hypercard_frame(%Frame{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do

        bm = _buffer_margin = 50 # px
        Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now
        # Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), :flex})

    end

    # def second_hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

    #     bm = _buffer_margin = 50 # px
    #     second_offset = 800
    #     Frame.new(top_left: {x+bm, y+bm+second_offset}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    # end
        
end
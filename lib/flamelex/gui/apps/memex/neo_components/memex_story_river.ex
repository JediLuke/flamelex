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

        IO.puts "SLEEEEEEEEEEEEEEEPPPPPPPPp #{inspect args}"

        new_graph = Scenic.Graph.build()
        #|> ScenicWidgets.FrameBox.add_to_graph(%{frame: args.frame, color: :antique_white})
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
            |> push_graph(new_graph)
    
            {:noreply, new_scene}
    end


    def render_tidbits(graph, %{state: %{open_tidbits: []}} = _story_river_state) do
        graph |> Scenic.Graph.delete(__MODULE__)
    end

    def render_tidbits(graph, %{state: %{open_tidbits: [%Memelex.TidBit{} = t], scroll: scroll}, frame: frame}) do
        new_graph = graph
        |> Scenic.Graph.delete(__MODULE__)
        |> Scenic.Primitives.group(fn graph ->
                # {_final_offset, final_graph} = 
                graph
                # |> ScenicWidgets.HyperCard.add_to_graph(%{
                |> ScenicWidgets.FrameBox.add_to_graph(%{
                        color: :antique_white,
                        frame: hypercard_frame(frame), # calculate hypercard based of story_river
                        data: t },
                        id: {:hypercard, t.uuid})


            end, [
                id: __MODULE__,
                translate: scroll
            ])
    end

    #     # def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, open_tidbits: [t]}} = scene) do
#     #     new_graph = graph
#     #     # |> Scenic.Graph.delete(:story_river)
#     #     # |> Scenic.Graph.delete(:hypercard) #TODO is this how it works with Components? Not sure...
#     #     |> common_render(frame, t, scene.assigns.scroll)
#     #     # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
#     #     #             id: :story_river,
#     #     #             fill: :beige,
#     #     #             translate: {
#     #     #                 frame.top_left.x,
#     #     #                 frame.top_left.y})
#     #     # |> HyperCard.add_to_graph(%{
#     #     #     frame: hypercard_frame(scene.assigns.frame), # calculate hypercard based of story_river
#     #     #     tidbit: t },
#     #     #     id: :hypercard)

#     #     # GenServer.call(HyperCard, {:re_render, %{frame: hypercard_frame(scene.assigns.frame)}})

#     #     scene
#     #     |> assign(graph: new_graph)
#     # end

    # def render_tidbits(graph, %{open_tidbits: open_tidbits_list} = _story_river_state) do
    #     graph
    #     |> Scenic.Primitives.group(fn graph ->
    #             {_final_offset, final_graph} = 
    #                 open_tidbits_list

    #         end, [
    #             id: __MODULE__,
    #             translate: scene.assigns.state.scroll
    #         ])
    #     end


    # end




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

    end

    # def second_hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

    #     bm = _buffer_margin = 50 # px
    #     second_offset = 800
    #     Frame.new(top_left: {x+bm, y+bm+second_offset}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    # end
        
end
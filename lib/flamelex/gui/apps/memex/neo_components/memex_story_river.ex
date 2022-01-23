defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end


    def init(scene, %{state: init_story_river_state} = args, opts) do
        Logger.debug "#{__MODULE__} initializing..."

        IO.puts "SLEEEEEEEEEEEEEEEPPPPPPPPp #{inspect args}"

        new_graph = Scenic.Graph.build()
        |> ScenicWidgets.FrameBox.add_to_graph(%{frame: args.frame, color: :antique_white})
        |> render_tidbits(init_story_river_state)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        new_scene = scene
        |> assign(graph: new_graph)
        |> assign(frame: args.frame)
        |> assign(state: init_story_river_state)
        |> push_graph(new_graph)

        {:ok, new_scene}
    end

    def handle_info({:radix_state_change, %{memex: %{story_river: new_story_river_state}}}, %{assigns: %{state: current_state}} = scene)
        when new_story_river_state != current_state do
            Logger.debug "#{__MODULE__} updating StoryRiver..."

            Logger.warn "NOT RLY UPDATING THE STORY RIVER YET"

            new_graph = Scenic.Graph.build()
            |> ScenicWidgets.FrameBox.add_to_graph(%{frame: scene.assigns.frame, color: :pink})
            |> render_tidbits(new_story_river_state)

            new_scene = scene
            |> assign(graph: new_graph)
            |> push_graph(new_graph)
    
            {:noreply, new_scene}
    end


    def render_tidbits(graph, %{open_tidbits: []} = _story_river_state) do
        graph
    end

    def render_tidbits(graph, %{open_tidbits: [t|rest]} = _story_river_state) do
        graph
        #     #     |> Scenic.Primitives.group(fn graph ->
#     #         {_final_offset, final_graph} = 
#     #             tidbit_list
#     #             |> Enum.reduce({0, graph}, fn
#     #                     tidbit, {offset = 0, acc_graph} ->
#     #                         IO.puts "AT LEAAST WE KNOW WERE HERE - RENDERING FIRST TIDBIT"
#     #                         # {left, bottom, right, top} = Scenic.Graph.bounds(acc_graph)
#     #                         # existing_graph_height = top-bottom
#     #                         # IO.inspect existing_graph_height, label: "EXISTT"
#     #                         new_acc_graph = acc_graph
#     #                         |> HyperCard.add_to_graph(%{
#     #                             frame:  Frame.new(top_left: {frame.top_left.x+bm, frame.top_left.y+bm}, dimensions: {frame.dimensions.width-(2*bm), 300}),
#     #                             # frame: hypercard_frame(frame), # calculate hypercard based of story_river
#     #                             tidbit: tidbit })
#     #                             # id: :hypercard,
#     #                             # t: scroll)

#     #                         {offset+1, new_acc_graph}
#     #                     tidbit, {offset, acc_graph} ->
#     #                         IO.puts "AT LEAAST WE KNOW WERE HERE 222222222222"
#     #                         #NOTE - Ok so I guess we can't use Bounds on graphs with components :thumbs_down:
#     #                         # we might have to get hypercards to call back with their height or something :thumbs_down:
#     #                         {left, bottom, right, top} = Scenic.Graph.bounds(acc_graph)
#     #                         # IO.inspect left, label: "left"
#     #                         # IO.inspect bottom, label: "bottom"
#     #                         # IO.inspect right, label: "right"
#     #                         # IO.inspect top, label: "top"
#     #                         existing_graph_height = top-bottom
#     #                         # IO.inspect existing_graph_height, label: "EXISTT"
#     #                         new_acc_graph = acc_graph
#     #                         |> HyperCard.add_to_graph(%{
#     #                             frame:  Frame.new(top_left: {frame.top_left.x+bm, existing_graph_height+bm}, dimensions: {frame.dimensions.width-(2*bm), 700}),
#     #                             # frame: hypercard_frame(frame), # calculate hypercard based of story_river
#     #                             tidbit: tidbit })
#     #                             # id: :hypercard,
#     #                             # t: scroll)

#     #                         {offset+1, new_acc_graph}
#     #             end)
#     #         final_graph
#     #     end, [
#     #         #NOTE: We will scroll this pane around later on, and need to
#     #         #      add new TidBits to it with Modify
#     #         id: :river_pane, # Scenic required we register groups/components with a name
#     #         translate: scroll
#     #     ])
#     # end


    end

#     # def common_render(graph, frame, %Memelex.TidBit{} = t, scroll) do
#     #     # this_frame = second_hypercard_frame(frame)



#     #     graph
#     #     |> Scenic.Primitives.group(fn graph ->
#     #         graph
#     #         |> HyperCard.add_to_graph(%{
#     #                 frame: hypercard_frame(frame), # calculate hypercard based of story_river
#     #                 tidbit: t })
#     #                 # id: :hypercard,
#     #                 # t: scroll)
#     #     end, [
#     #         #NOTE: We will scroll this pane around later on, and need to
#     #         #      add new TidBits to it with Modify
#     #         id: :river_pane, # Scenic required we register groups/components with a name
#     #         translate: scroll
#     #     ])
#     # end

#     # def common_render(graph, frame, tidbit_list, scroll) when is_list(tidbit_list) do
#     #     # this_frame = second_hypercard_frame(frame)
#     #     bm = 15
#     #     graph












        #           |> LayoutList.add_to_graph(%{
#                 id: :story_layout_list, #TODO lol
#                 frame: params.frame,
#                 # components: calc_component_list(open_tidbits)
#                 components: [],
#                     # %{module: HyperCard, params: hd(open_tidbits), opts: []} #TODO?
#                 layout: :flex_grow,
#                 scroll: true
#           }, id: :story_layout_list) #TODO lol

end
defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard
    alias Flamelex.GUI.Component.LayoutList

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end

    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        {:ok, open_tidbits} =
            GenServer.call(Flamelex.GUI.StageManager.Memex, :get_open_tidbits)

        new_graph =
          Scenic.Graph.build()
          |> LayoutList.add_to_graph(%{
                id: :story_layout_list, #TODO lol
                frame: params.frame,
                # components: calc_component_list(open_tidbits)
                components: [],
                    # %{module: HyperCard, params: hd(open_tidbits), opts: []} #TODO?
                layout: :flex_grow,
                scroll: true
          }, id: :story_layout_list) #TODO lol

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:ok, new_scene}
    end

    # def calc_component_list([t|rest]) do
    #     init_list = [{HyperCard, t, _opts = [id: HyperCard.rego(t)]}] #TODO this is where we probs ought to make our own component, havibng data & opts seperate sucks

    #     calc_component_list(init_list, rest)
    # end

    # def calc_component_list(results, []), do: results

    # def calc_component_list(results, [t|rest]) do
    #     calc_component_list(results ++ [{HyperCard, t, []}], rest)
    # end

    def component(%{module: mod, params: p, opts: o}) do
        [module: mod, params: p, opts: o]
    end
    
    def handle_input(input, context, scene) do
        Logger.debug "#{__MODULE__} ignoring some input: #{inspect input}"
        {:noreply, scene}
    end


    # def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, open_tidbits: [t]}} = scene) do
    #     new_graph = graph
    #     # |> Scenic.Graph.delete(:story_river)
    #     # |> Scenic.Graph.delete(:hypercard) #TODO is this how it works with Components? Not sure...
    #     |> common_render(frame, t, scene.assigns.scroll)
    #     # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #     #             id: :story_river,
    #     #             fill: :beige,
    #     #             translate: {
    #     #                 frame.top_left.x,
    #     #                 frame.top_left.y})
    #     # |> HyperCard.add_to_graph(%{
    #     #     frame: hypercard_frame(scene.assigns.frame), # calculate hypercard based of story_river
    #     #     tidbit: t },
    #     #     id: :hypercard)

    #     # GenServer.call(HyperCard, {:re_render, %{frame: hypercard_frame(scene.assigns.frame)}})

    #     scene
    #     |> assign(graph: new_graph)
    # end

    # def common_render(graph, frame, %Memex.TidBit{} = t, scroll) do
    #     # this_frame = second_hypercard_frame(frame)



    #     graph
    #     |> Scenic.Primitives.group(fn graph ->
    #         graph
    #         |> HyperCard.add_to_graph(%{
    #                 frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #                 tidbit: t })
    #                 # id: :hypercard,
    #                 # t: scroll)
    #     end, [
    #         #NOTE: We will scroll this pane around later on, and need to
    #         #      add new TidBits to it with Modify
    #         id: :river_pane, # Scenic required we register groups/components with a name
    #         translate: scroll
    #     ])
    # end

    # def common_render(graph, frame, tidbit_list, scroll) when is_list(tidbit_list) do
    #     # this_frame = second_hypercard_frame(frame)
    #     bm = 15
    #     graph
    #     |> Scenic.Primitives.group(fn graph ->
    #         {_final_offset, final_graph} = 
    #             tidbit_list
    #             |> Enum.reduce({0, graph}, fn
    #                     tidbit, {offset = 0, acc_graph} ->
    #                         IO.puts "AT LEAAST WE KNOW WERE HERE - RENDERING FIRST TIDBIT"
    #                         # {left, bottom, right, top} = Scenic.Graph.bounds(acc_graph)
    #                         # existing_graph_height = top-bottom
    #                         # IO.inspect existing_graph_height, label: "EXISTT"
    #                         new_acc_graph = acc_graph
    #                         |> HyperCard.add_to_graph(%{
    #                             frame:  Frame.new(top_left: {frame.top_left.x+bm, frame.top_left.y+bm}, dimensions: {frame.dimensions.width-(2*bm), 300}),
    #                             # frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #                             tidbit: tidbit })
    #                             # id: :hypercard,
    #                             # t: scroll)

    #                         {offset+1, new_acc_graph}
    #                     tidbit, {offset, acc_graph} ->
    #                         IO.puts "AT LEAAST WE KNOW WERE HERE 222222222222"
    #                         #NOTE - Ok so I guess we can't use Bounds on graphs with components :thumbs_down:
    #                         # we might have to get hypercards to call back with their height or something :thumbs_down:
    #                         {left, bottom, right, top} = Scenic.Graph.bounds(acc_graph)
    #                         # IO.inspect left, label: "left"
    #                         # IO.inspect bottom, label: "bottom"
    #                         # IO.inspect right, label: "right"
    #                         # IO.inspect top, label: "top"
    #                         existing_graph_height = top-bottom
    #                         # IO.inspect existing_graph_height, label: "EXISTT"
    #                         new_acc_graph = acc_graph
    #                         |> HyperCard.add_to_graph(%{
    #                             frame:  Frame.new(top_left: {frame.top_left.x+bm, existing_graph_height+bm}, dimensions: {frame.dimensions.width-(2*bm), 700}),
    #                             # frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #                             tidbit: tidbit })
    #                             # id: :hypercard,
    #                             # t: scroll)

    #                         {offset+1, new_acc_graph}
    #             end)
    #         final_graph
    #     end, [
    #         #NOTE: We will scroll this pane around later on, and need to
    #         #      add new TidBits to it with Modify
    #         id: :river_pane, # Scenic required we register groups/components with a name
    #         translate: scroll
    #     ])
    # end

    # def hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

    #     bm = _buffer_margin = 50 # px
    #     Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    # end

    # def second_hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

    #     bm = _buffer_margin = 50 # px
    #     second_offset = 800
    #     Frame.new(top_left: {x+bm, y+bm+second_offset}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    # end
        

    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end

    # def handle_cast({:replace_tidbit, tidbit}, _from, scene) do
    #     {:noreply, scene}
    # end

    # def handle_cast(:render_flex_layout, scene) do
    #     td = scene.assigns.unrendered_tidbits
    # end


    def handle_cast({:add_tidbit, tidbit}, scene) do
        IO.puts "RECVd recuqest to add tidbit"
        # ic tidbit
        :ok = GenServer.call(Flamelex.GUI.Component.LayoutList, {:add_tidbit, tidbit})
        {:noreply, scene}
    end

    def handle_cast({:clicked_edit_tidbit, title}, scene) do
        IO.puts "EDITING #{inspect title}" 
        GenServer.cast(title |> String.to_atom, :edit_mode)
        {:noreply, scene}
    end





    # #NOTE - you know, this is really the only thing that changes... all
    # #       the above is Boilerplate

    # def render(scene) do
    #     ##TODO next steps

    #     # we have the hypercard component - we want to really robustify
    #     # that component
    #     #
    #     # then we want to be able to get the sidebar happening with "recent",
    #     # "open" etc.
    #     #
    #     # then we want to be able to edit TidBits
    #     #
    #     # Scrolling doesn't even have to come till like last, we can just
    #     # flick through left/right
    #     scene
    # end

    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     Logger.debug "#{__MODULE__} re-rendering..."
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end
end


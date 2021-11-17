defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard

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


        # get a random one for now
        # tidbit = Memex.My.Wiki.list |> Enum.random()
        {:ok, open_tidbits} = GenServer.call(Flamelex.GUI.StageManager.Memex, :get_open_tidbits)

        new_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
        |> assign(scroll: {0, 0})
        |> assign(open_tidbits: open_tidbits)
        |> render_push_graph()
    
        request_input(new_scene, [:cursor_scroll])

        {:ok, new_scene}
    end

    def handle_input({:cursor_scroll, {{_x_scroll, _y_scroll} = delta_scroll, coords}}, _context, scene) do
        Logger.warn "#{__MODULE__} getting :scroll"
        # Logger.debug "Handling right scrolling - "

        new_cumulative_scroll =
            Scenic.Math.Vector2.add(scene.assigns.scroll, delta_scroll)

        new_graph = scene.assigns.graph
            |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: new_cumulative_scroll))

        # new_state = scene.assigns
        #     |> Map.merge(%{scroll: new_cumulative_scroll})

        # # new_graph = render(state, first_render?: true)
        new_scene = scene
        |> assign(graph: new_graph)
        # |> assign(state: new_state)
        |> push_graph(new_graph)

        {:noreply, scene |> assign(scroll: new_cumulative_scroll)}
    end
    
    def handle_input(input, context, scene) do
        Logger.debug "#{__MODULE__} ignoring some input: #{inspect input}"
        {:noreply, scene}
    end

    def re_render(scene) do
        GenServer.call(__MODULE__, {:re_render, scene})
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, open_tidbits: [t]}} = scene) do
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: :story_river,
                    fill: :beige,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y })
            |> common_render(frame, t, scene.assigns.scroll)
            # |> HyperCard.add_to_graph(%{
            #         frame: hypercard_frame(scene.assigns.frame), # calculate hypercard based of story_river
            #         tidbit: t },
            #         id: :hypercard)

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, open_tidbits: [t]}} = scene) do
        new_graph = graph
        # |> Scenic.Graph.delete(:story_river)
        # |> Scenic.Graph.delete(:hypercard) #TODO is this how it works with Components? Not sure...
        |> common_render(frame, t, scene.assigns.scroll)
        # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
        #             id: :story_river,
        #             fill: :beige,
        #             translate: {
        #                 frame.top_left.x,
        #                 frame.top_left.y})
        # |> HyperCard.add_to_graph(%{
        #     frame: hypercard_frame(scene.assigns.frame), # calculate hypercard based of story_river
        #     tidbit: t },
        #     id: :hypercard)

        # GenServer.call(HyperCard, {:re_render, %{frame: hypercard_frame(scene.assigns.frame)}})

        scene
        |> assign(graph: new_graph)
    end

    def common_render(graph, frame, %Memex.TidBit{} = t, scroll) do
        # this_frame = second_hypercard_frame(frame)
        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> HyperCard.add_to_graph(%{
                    frame: hypercard_frame(frame), # calculate hypercard based of story_river
                    tidbit: t })
                    # id: :hypercard,
                    # t: scroll)
        end, [
            #NOTE: We will scroll this pane around later on, and need to
            #      add new TidBits to it with Modify
            id: :river_pane, # Scenic required we register groups/components with a name
            translate: scroll
        ])
    end

    def common_render(graph, frame, tidbit_list, scroll) when is_list(tidbit_list) do
        # this_frame = second_hypercard_frame(frame)
        bm = 15
        graph
        |> Scenic.Primitives.group(fn graph ->
            {_final_offset, final_graph} = 
                tidbit_list
                |> Enum.reduce({0, graph}, fn tidbit, {offset, acc_graph} ->
                    new_acc_graph = acc_graph
                    |> HyperCard.add_to_graph(%{
                        frame:  Frame.new(top_left: {frame.top_left.x+bm, frame.top_left.y+bm+(offset*400)}, dimensions: {frame.dimensions.width-(2*bm), 700}),
                        # frame: hypercard_frame(frame), # calculate hypercard based of story_river
                        tidbit: tidbit })
                        # id: :hypercard,
                        # t: scroll)

                    {offset+1, new_acc_graph}
                end)
            final_graph
        end, [
            #NOTE: We will scroll this pane around later on, and need to
            #      add new TidBits to it with Modify
            id: :river_pane, # Scenic required we register groups/components with a name
            translate: scroll
        ])
    end

    def hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

        bm = _buffer_margin = 50 # px
        Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    end

    def second_hypercard_frame(%Frame{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}}) do

        bm = _buffer_margin = 50 # px
        second_offset = 800
        Frame.new(top_left: {x+bm, y+bm+second_offset}, dimensions: {w-(2*bm), 700}) #TODO just hard-code hypercards at 700 high for now

    end
        

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

    def handle_cast({:replace_tidbit, tidbit}, _from, scene) do
        {:noreply, scene}
    end


    def handle_cast({:add_tidbit, tidbit}, scene) do
        IO.puts "YES ADD TIDBIT"
        frame = scene.assigns.frame

        new_tidbit_list = scene.assigns.open_tidbits ++ [tidbit]
        # new_graph = scene.assigns.graph
        # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
        # # id: :story_river,
        # fill: :blue,
        # translate: {
        #     frame.top_left.x,
        #     frame.top_left.y+600 })

        # new_graph = scene.assigns.graph
        # |> HyperCard.add_to_graph(%{
        #         frame: hypercard_frame(frame), # calculate hypercard based of story_river
        #         tidbit: tidbit },
        #         id: :hypercard,
        #         t: scene.assigns.scroll)

        #TODO modify :river_pane - HERE

        new_graph = scene.assigns.graph
        |> Scenic.Graph.delete(:river_pane)
        |> common_render(scene.assigns.frame, new_tidbit_list, scene.assigns.scroll)
        # |> Scenic.Graph.modify(:river_pane, fn group ->
        #     graph
        #     |> HyperCard.add_to_graph(%{
        #             frame: second_hypercard_frame(frame), # calculate hypercard based of story_river
        #             tidbit: tidbit })
        #             # id: :hypercard,
        #             # t: scroll)
        
        # end)
        #     |> Scenic.Primitives.group(fn graph ->
        #     graph
        #     |> HyperCard.add_to_graph(%{
        #             frame: hypercard_frame(frame), # calculate hypercard based of story_river
        #             tidbit: t })
        #             # id: :hypercard,
        #             # t: scroll)
        # end, [
        #     #NOTE: We will scroll this pane around later on, and need to
        #     #      add new TidBits to it with Modify
        #     id: :river_pane, # Scenic required we register groups/components with a name
        #     translate: scroll
        # ])
        
        # &text(&1, "Updated Text 3") )

        new_scene = scene
        |> assign(graph: new_graph)
        |> assign(open_tidbits: new_tidbit_list)
        |> push_graph(new_graph)

        {:noreply, new_scene}
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
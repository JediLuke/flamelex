defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.Tabs do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard.OneTab

    @component_id :hypercard_sidebar_tabs
    @background_color :forest_green

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end


    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        init_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
        |> assign(active_tab: "Open")
        |> render_push_graph()

        request_input(init_scene, [:cursor_button])

        {:ok, init_scene}
    end

    def re_render(scene) do
        GenServer.call(__MODULE__, {:re_render, scene})
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{first_render?: true, active_tab: "Open", frame: %Frame{} = frame, tabs: tabs}} = scene) do
        first_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: @component_id,
                    fill: @background_color,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y })

        #TODO this adds new tabs in to the bar
        tab_width = 72
        {new_graph, _final_offset} =
            Enum.reduce(tabs, {first_graph, 0}, fn(tab, {%Scenic.Graph{} = graph, offset}) ->
                tab_frame = Frame.new(
                                top_left: {frame.top_left.x+(offset*tab_width), frame.top_left.y},
                                dimensions: {tab_width, frame.dimensions.height})
                color = Enum.random([:orange, :pink, :purple, :brown, :blue])

                updated_graph = graph
                # |> Scenic.Primitives.text(tab,
                #         font: :ibm_plex_mono,
                #         translate: {10+frame.top_left.x+(offset*67), frame.top_left.y+frame.dimensions.height/2+10}, # text draws from bottom-left corner??
                #         font_size: 20,
                #         fill: :black)
                |> OneTab.add_to_graph(%{frame: tab_frame, label: tab, color: color}, id: {:tab, tab})

                {updated_graph, offset+1}
            end)

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: @component_id,
                    fill: @background_color,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})

        scene
        |> assign(graph: new_graph)
    end
    
    # def render_real(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        
    # end



    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

    # def handle_input(input, _context, scene) do
    #     # pass all input up to the parent scene
    #     IO.puts "TABS BAR GOT THE INPUT: #{inspect input}"
    #     ic input
    #     {:cont, input, scene}
    # end

    def handle_event(event, _context, scene) do
        IO.puts "SOME  IGNORED event #{inspect event}"
        # Flamelex.Fluxus.handle_user_input(input)
        {:noreply, scene}
    end

end
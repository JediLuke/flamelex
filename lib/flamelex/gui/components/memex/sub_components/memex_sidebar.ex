defmodule Flamelex.GUI.Component.Memex.SideBar do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar

    # @tabs ["Open", "Recent", "EXPERIMENTAL!?","More"]
    @tabs ["Open", "Recent", "More"]

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

        init_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
        |> assign(active_tab: "Open")
        |> render_push_graph()
    

        {:ok, init_scene}
    end

    def re_render(scene) do
        GenServer.call(__MODULE__, {:re_render, scene})
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, active_tab: "Open"}} = scene) do
        
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: :sidebar_bg,
                    fill: :light_blue,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})
            |> Scenic.Primitives.line(sidebar_line_spec(scene.assigns.frame),
                    id: :sidebar_line,
                    stroke: {2, :antique_white})
            |> Scenic.Primitives.line(sidebar_line_two_spec(scene.assigns.frame),
                id: :sidebar_line_two,
                stroke: {2, :antique_white})
            |> Sidebar.Tabs.add_to_graph(%{
                    tabs: @tabs,
                    frame: sidebar_tabs_frame(scene.assigns.frame)},
                    id: :sidebar_tabs)
            |> Sidebar.OpenTidBits.add_to_graph(%{
                open_tidbits: ["Luke", "Leah"],
                frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
                # id: {:sidebar, :low_pane, "Open"})
                id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time
                

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(:sidebar_bg)
        |> Scenic.Graph.delete(:sidebar_line)
        |> Scenic.Graph.delete(:sidebar_line_two)
        |> Scenic.Graph.delete(:sidebar_tabs)
        |> Scenic.Graph.delete(:sidebar_lowpane)
        |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                id: :sidebar_bg,
                fill: :light_blue,
                translate: {
                    frame.top_left.x,
                    frame.top_left.y})
        |> Scenic.Primitives.line(sidebar_line_spec(scene.assigns.frame),
                id: :sidebar_line,
                stroke: {2, :antique_white})
        |> Scenic.Primitives.line(sidebar_line_two_spec(scene.assigns.frame),
                id: :sidebar_line_two,
                stroke: {2, :antique_white})
        |> Sidebar.Tabs.add_to_graph(%{
            tabs: @tabs,
            frame: sidebar_tabs_frame(scene.assigns.frame)},
            id: :sidebar_tabs)
        #TODO this should depend on some kind of state
        |> Sidebar.OpenTidBits.add_to_graph(%{
            open_tidbits: ["Luke", "Leah"],
            frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
            # id: {:sidebar, :low_pane, "Open"})
            id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

        scene
        |> assign(graph: new_graph)
    end

    def sidebar_line_spec(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        title_height = 60
        buffer_margin = 20
        external_margin = 0
        line_y = 3*title_height + 2*buffer_margin
        {{x, y+line_y+external_margin}, {x+w, y+line_y+external_margin}} # extra 50 is the external margin
    end

    def sidebar_line_two_spec(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        title_height = 60
        buffer_margin = 20
        dateline_height = 40 # from elsewhere in the app (lol)
        external_margin = 0
        line_y = 3*title_height + 2*buffer_margin
        {{x, y+line_y+external_margin+dateline_height}, {x+w, y+line_y+external_margin+dateline_height}} # extra 50 is the external margin
    end

    def sidebar_tabs_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        title_height = 60
        buffer_margin = 20
        tab_bar_height = dateline_height = 40 # from elsewhere in the app (lol)
        external_margin = 0
        line_y = 3*title_height + 2*buffer_margin
        height_of_top_section = y+line_y+external_margin+dateline_height
        Frame.new(
            top_left: {x, y+height_of_top_section},
            dimensions: {w, tab_bar_height})
    end

    def sidebar_open_tidbits_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        title_height = 60
        buffer_margin = 20
        tab_bar_height = dateline_height = 40 # from elsewhere in the app (lol)
        external_margin = 0
        line_y = 3*title_height + 2*buffer_margin
        height_of_top_section = y+line_y+external_margin+dateline_height


        Frame.new(
            top_left: {x, y+height_of_top_section+tab_bar_height},
            dimensions: {w, h-height_of_top_section-tab_bar_height})
    end

    def handle_input(input, _context, scene) do
        ic input
        {:noreply, scene}
    end

    def handle_cast({:open_tab, "More"}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(:sidebar_lowpane)
        |> Sidebar.MoreFeatures.add_to_graph(%{
            open_tidbits: ["Luke", "Leah"],
            frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
            # id: {:sidebar, :low_pane, "Open"})
            id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    def handle_cast({:open_tab, _else}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(:sidebar_lowpane)
        |> Sidebar.OpenTidBits.add_to_graph(%{
            open_tidbits: ["Luke", "Leah"],
            frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
            # id: {:sidebar, :low_pane, "Open"})
            id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end



    #NOTE - you know, this is really the only thing that changes... all
    #       the above is Boilerplate

    # def render(scene) do
    #     scene |> Draw.background(:light_blue)
    # end

    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end
end
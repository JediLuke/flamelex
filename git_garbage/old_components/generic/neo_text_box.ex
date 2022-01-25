defmodule Flamelex.GUI.Component.Generic.NeoTextBox do
    use Flamelex.GUI.ComponentBehaviour
    alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar
    use ScenicWidgets.ScenicEventsDefinitions

    def validate(%{state: %{
            margin: margin,
            header_height: header_height,
            width: width,
            data: text,
            font_size: font_size
    }} = data) do
        {:ok, data}
    end

    def custom_init_logic(_scene, args) do
        # request_input(scene, [:key])
        args
    end

    # STEP 1 - a border
    # Step 2 - a cursor
    # step 3 - working test editing
    # step 4 - use this for header aswell

    def render(graph, %{state: %{
            margin: margin,
            header_height: header_height,
            width: width,
            tidbit: tidbit,
            font_size: font_size
    }, frame: frame} = args) do

        textbox_width = width-margin.left-margin.right
        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf") #TODO put this in the %Scene{} maybe?
        wrapped_text = FontMetrics.wrap(tidbit.data, textbox_width, font_size, metrics)

        # bottom - top / descent - ascent
        ascent = FontMetrics.ascent(font_size, metrics)
        d = FontMetrics.descent(font_size, metrics)

        text_height = ascent+(d*-1)

        num_lines = String.split(wrapped_text, "\n", trim: true) |> Enum.count()
        ic num_lines

        text_box_height = num_lines * text_height

        dimens = %{height: text_box_height, width: textbox_width}
        ic dimens

        {x_position, line_num} = FontMetrics.position_at(wrapped_text, String.length(wrapped_text), font_size, metrics)
        ic x_position
        ic line_num

        graph
        # |> Scenic.Primitives.rect({250, 250}, t: {500, 500}, fill: :yellow)
        |> Draw.border_box(%{x: 0, y: 0-ascent} |> Map.merge(dimens), {1, :black})
        |> Scenic.Primitives.text(wrapped_text,
            font: :ibm_plex_mono,
            font_size: font_size,
            fill: :black)
            #TODO - how to draw a flexibly high border, which depends on how
            #       high the above text is - obviously I need to calculate
            #       how high this text is, that's not obviously easy to me how to do...
            # translate: {margin.left, margin.top+font_size}) #TODO this should actually be, one line height
            # translate: {margin.left, margin.top+font_size}) #TODO this should actually be, one line height
        |> Scenic.Primitives.rect({5,30}, fill: :white, t: {x_position,(line_num-1)*text_height})
    end
 
    # def render(graph, %{first_render?: true, frame: frame, state: %{mode: :normal}}) do
    #    full_frame = {w, h} = {frame.dimensions.width, frame.dimensions.height}
    #    graph
    #    |> Scenic.Primitives.rect(full_frame, fill: :grey)
    # #    |> Sidebar.TabsTwo.mount(%{
    # #         ref: :tabs_menu,
    # #         frame: Frame.new(pin: {0, @search_box_offset}, size: {w, @search_box_height}),
    # #         state: %{mode: :inactive, tabs: ["Open", "Recent", "More"]}
    # #     })
    #     |> Sidebar.Tabs.add_to_graph(%{
    #         tabs: ["Open", "Recent", "More"],
    #         frame: Frame.new(pin: {0, 0}, size: {w, @tabs_menu_height}),
    #         id: :sidebar_tabs}, id: :sidebar_tabs)
    #     |> Sidebar.OpenTidBits.add_to_graph(%{
    #         open_tidbits: ["Luke", "Leah"],
    #         frame: Frame.new(pin: {0, @tabs_menu_height}, size: {w, h-@tabs_menu_height})},
    #         # frame: sidebar_open_tidbits_frame(frame)},
    #         # id: {:sidebar, :low_pane, "Open"})
    #         id: :sidebar_open_tidbits) # they all use this save id, so we can just delete this every time
    # end


    # def handle_cast({:open_tab, "More"}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
    #     full_frame = {w, h} = {frame.dimensions.width, frame.dimensions.height}
    #     new_graph = graph
    #     |> Scenic.Graph.delete(:sidebar_tabs)
    #     |> Scenic.Graph.delete(:sidebar_memex_control)
    #     |> Scenic.Graph.delete(:sidebar_open_tidbits)
    #     |> Scenic.Graph.delete(:sidebar_search_results)
    #     |> Sidebar.Tabs.add_to_graph(%{
    #         tabs: ["Open", "Recent", "More"],
    #         frame: Frame.new(pin: {0, 0}, size: {w, @tabs_menu_height}),
    #         id: :sidebar_tabs}, id: :sidebar_tabs, t: frame.pin)
    #     |> Sidebar.MoreFeatures.add_to_graph(%{
    #         # open_tidbits: ["Luke", "Leah"],
    #         frame: Frame.new(pin: {0, @tabs_menu_height}, size: {w, h-@tabs_menu_height}),
    #         # id: {:sidebar, :low_pane, "Open"})
    #         id: :sidebar_memex_control}, id: :sidebar_memex_control, t: frame.pin) # they all use this save id, so we can just delete this every time

    #     new_state = scene.assigns.state |> Map.merge(%{mode: :normal})

    #     new_scene = scene
    #     |> assign(state: new_state)
    #     |> assign(graph: new_graph)
    #     |> push_graph(new_graph)

    #     {:noreply, new_scene}
    # end

    # def handle_cast({:open_tab, _else}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
    #     full_frame = {w, h} = {frame.dimensions.width, frame.dimensions.height}
    #     new_graph = graph
    #     |> Scenic.Graph.delete(:sidebar_tabs)
    #     |> Scenic.Graph.delete(:sidebar_memex_control)
    #     |> Scenic.Graph.delete(:sidebar_open_tidbits)
    #     |> Scenic.Graph.delete(:sidebar_search_results)
    #     |> Sidebar.Tabs.add_to_graph(%{
    #         tabs: ["Open", "Recent", "More"],
    #         frame: Frame.new(pin: {0, 0}, size: {w, @tabs_menu_height}),
    #         id: :sidebar_tabs}, id: :sidebar_tabs, t: frame.pin)
    #     |> Sidebar.OpenTidBits.add_to_graph(%{
    #         open_tidbits: ["Luke", "Leah"],
    #         frame: Frame.new(pin: {0, @tabs_menu_height}, size: {w, h-@tabs_menu_height})},
    #         # frame: sidebar_open_tidbits_frame(frame)},
    #         # id: {:sidebar, :low_pane, "Open"})
    #         id: :sidebar_open_tidbits, t: frame.pin) # they all use this save id, so we can just delete this every time

    #     new_state = scene.assigns.state |> Map.merge(%{mode: :normal})

    #     new_scene = scene
    #     |> assign(state: new_state)
    #     |> assign(graph: new_graph)
    #     |> push_graph(new_graph)

    #     {:noreply, new_scene}
    # end



    # def handle_cast({:search, search_term}, %{assigns: %{state: %{mode: :normal}}} = scene) do
    #     {w, h} = {scene.assigns.frame.dimensions.width, scene.assigns.frame.dimensions.height}

    #     new_graph = scene.assigns.graph
    #     |> Scenic.Graph.delete(:sidebar_tabs)
    #     |> Scenic.Graph.delete(:sidebar_memex_control)
    #     |> Scenic.Graph.delete(:sidebar_open_tidbits)
    #     |> Scenic.Graph.delete(:sidebar_search_results)
    #     |> Sidebar.SearchResults.add_to_graph(%{
    #         results: [],
    #         frame: Frame.new(pin: {0, 0}, size: {w, h})},
    #         id: :sidebar_search_results, t: scene.assigns.frame.pin)

    #     new_state = scene.assigns.state |> Map.merge(%{mode: :search})

    #     new_scene = scene
    #     |> assign(state: new_state)
    #     |> assign(graph: new_graph)
    #     |> push_graph(new_graph)

    #     {:noreply, new_scene}
    #  end

    #  #TODO note that fkin text input box fucks everything up... it captures keystrokes!!

    #  def handle_cast({:search, search_term}, %{assigns: %{state: %{mode: :search}}} = scene) do
    #     # {:ok, [sidebar_search_results: pid]} = Scenic.Scene.children(scene)
    #     {:ok, children} = Scenic.Scene.children(scene)
    #     children |> Enum.map(fn {:sidebar_search_results, pid} ->
    #                                 GenServer.cast(pid, {:search, search_term})
    #                             _else ->
    #                                 :ok
    #                         end)
        
    #     {:noreply, scene}
    #  end

    #  def handle_input(@escape_key, _context, %{assigns: %{state: %{mode: :search}, frame: frame}} = scene) do
    #     full_frame = {w, h} = {frame.dimensions.width, frame.dimensions.height}

    #     {:gui_component, Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchBox, :search_box}
    #     |> ProcessRegistry.find!()
    #     |> GenServer.cast(:deactivate)

    #     IO.puts "YEYERYERY"
    #     new_graph = scene.assigns.graph
    #     |> Scenic.Graph.delete(:sidebar_tabs)
    #     |> Scenic.Graph.delete(:sidebar_memex_control)
    #     |> Scenic.Graph.delete(:sidebar_open_tidbits)
    #     |> Scenic.Graph.delete(:sidebar_search_results)
    #     |> Sidebar.Tabs.add_to_graph(%{
    #         tabs: ["Open", "Recent", "More"],
    #         frame: Frame.new(pin: {0, 0}, size: {w, @tabs_menu_height}),
    #         id: :sidebar_tabs}, id: :sidebar_tabs, t: frame.pin)
    #     |> Sidebar.OpenTidBits.add_to_graph(%{
    #         open_tidbits: ["Luke", "Leah"],
    #         frame: Frame.new(pin: {0, @tabs_menu_height}, size: {w, h-@tabs_menu_height})},
    #         # frame: sidebar_open_tidbits_frame(frame)},
    #         # id: {:sidebar, :low_pane, "Open"})
    #         id: :sidebar_open_tidbits, t: frame.pin) # they all use this save id, so we can just delete this every time

    #     new_state = scene.assigns.state |> Map.merge(%{mode: :normal})

    #     new_scene = scene
    #     |> assign(state: new_state)
    #     |> assign(graph: new_graph)
    #     |> push_graph(new_graph)

    #     {:noreply, new_scene}
    #   end

    #  def handle_input(unrecognised_input, _context, scene) do
    #     ic unrecognised_input

    #     {:noreply, scene}
    #  end
 end
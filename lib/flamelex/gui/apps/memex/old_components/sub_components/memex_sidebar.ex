

#             |> Sidebar.SearchBox.add_to_graph(%{
#                     mode: :inactive,
#                     frame: search_box_frame(scene.assigns.frame)},
#                     id: :search_box)
#             |> Sidebar.Tabs.add_to_graph(%{
#                     tabs: @tabs,
#                     frame: sidebar_tabs_frame(scene.assigns.frame)},
#                     id: :sidebar_tabs)
#             |> Sidebar.OpenTidBits.add_to_graph(%{
#                 open_tidbits: ["Luke", "Leah"],
#                 frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#                 # id: {:sidebar, :low_pane, "Open"})
#                 id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time
#             |> Sidebar.SearchResults.add_to_graph(%{
#                 results: [],
#                 frame: sidebar_search_results_frame(scene.assigns.frame)},
#                 # id: {:sidebar, :low_pane, "Open"})
#                 id: :sidebar_search_results,
#                 hidden: true)
                

#         scene
#         |> assign(graph: new_graph)
#         |> assign(first_render?: false)
#     end

#     def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
#         new_graph = graph
#         |> Scenic.Graph.delete(:sidebar_bg)
#         |> Scenic.Graph.delete(:sidebar_line)
#         |> Scenic.Graph.delete(:sidebar_line_two)
#         |> Scenic.Graph.delete(:sidebar_tabs)
#         |> Scenic.Graph.delete(:sidebar_lowpane)
#         |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
#                 id: :sidebar_bg,
#                 fill: :light_blue,
#                 translate: {
#                     frame.top_left.x,
#                     frame.top_left.y})
#         |> Scenic.Primitives.line(sidebar_line_spec(scene.assigns.frame),
#                 id: :sidebar_line,
#                 stroke: {2, :antique_white})
#         |> Scenic.Primitives.line(sidebar_line_two_spec(scene.assigns.frame),
#                 id: :sidebar_line_two,
#                 stroke: {2, :antique_white})
#         |> Sidebar.Tabs.add_to_graph(%{
#             tabs: @tabs,
#             frame: sidebar_tabs_frame(scene.assigns.frame)},
#             id: :sidebar_tabs)
#         #TODO this should depend on some kind of state
#         |> Sidebar.OpenTidBits.add_to_graph(%{
#             open_tidbits: ["Luke", "Leah"],
#             frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#             # id: {:sidebar, :low_pane, "Open"})
#             id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time
#         |> Sidebar.SearchResults.add_to_graph(%{
#                 results: [],
#                 frame: sidebar_search_results_frame(scene.assigns.frame)},
#                 # id: {:sidebar, :low_pane, "Open"})
#                 id: :sidebar_search_results,
#                 hidden: true)

#         scene
#         |> assign(graph: new_graph)
#     end

#     def sidebar_line_spec(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#         title_height = 60
#         buffer_margin = 20
#         external_margin = 0
#         line_y = 3*title_height + 2*buffer_margin
#         {{x, y+line_y+external_margin}, {x+w, y+line_y+external_margin}} # extra 50 is the external margin
#     end

#     def sidebar_line_two_spec(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#         title_height = 60
#         buffer_margin = 20
#         dateline_height = 40 # from elsewhere in the app (lol)
#         external_margin = 0
#         line_y = 3*title_height + 2*buffer_margin
#         {{x, y+line_y+external_margin+dateline_height}, {x+w, y+line_y+external_margin+dateline_height}} # extra 50 is the external margin
#     end

#     def search_box_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do

#         title_height = 60
#         buffer_margin = 20
#         dateline_height = 40 # from elsewhere in the app (lol)
#         external_margin = 0
#         line_y = 3*title_height + 2*buffer_margin

#         dateline_height = 40 # from elsewhere in the app (lol)

#         Frame.new(
#             top_left: {x, y+line_y+external_margin},
#             dimensions: {w, dateline_height})
#     end

#     def sidebar_tabs_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#         title_height = 60
#         buffer_margin = 20
#         tab_bar_height = dateline_height = 40 # from elsewhere in the app (lol)
#         external_margin = 0
#         line_y = 3*title_height + 2*buffer_margin
#         height_of_top_section = y+line_y+external_margin+dateline_height
#         Frame.new(
#             top_left: {x, y+height_of_top_section},
#             dimensions: {w, tab_bar_height})
#     end



#     def sidebar_search_results_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#         title_height = 60
#         buffer_margin = 20
#         tab_bar_height = dateline_height = 40 # from elsewhere in the app (lol)
#         external_margin = 0
#         line_y = 3*title_height + 2*buffer_margin
#         height_of_top_section = y+line_y+external_margin+dateline_height

#         Frame.new(
#             top_left: {x, y+height_of_top_section},
#             dimensions: {w, h-height_of_top_section})
#     end

#     def handle_input(input, _context, scene) do
#         ic input
#         {:noreply, scene}
#     end

#     def handle_cast({:open_tab, "More"}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
#         new_graph = graph
#         |> Scenic.Graph.delete(:sidebar_lowpane)
#         |> Sidebar.MoreFeatures.add_to_graph(%{
#             open_tidbits: ["Luke", "Leah"],
#             frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#             # id: {:sidebar, :low_pane, "Open"})
#             id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#         {:noreply, new_scene}
#     end

#     def handle_cast({:open_tab, _else}, %{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
#         new_graph = graph
#         |> Scenic.Graph.delete(:sidebar_lowpane)
#         |> Sidebar.OpenTidBits.add_to_graph(%{
#             open_tidbits: ["Luke", "Leah"],
#             frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#             # id: {:sidebar, :low_pane, "Open"})
#             id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#         {:noreply, new_scene}
#     end

#     def handle_cast({:switch_mode, :search}, scene) do
#         IO.puts "GOING INTO SEARCH MODE"
#         new_graph = scene.assigns.graph
#         # |> Scenic.Graph.delete(:sidebar_tabs)
#         # |> Scenic.Graph.delete(:sidebar_lowpane)
#         # |> Sidebar.OpenTidBits.add_to_graph(%{
#         #     open_tidbits: ["Luke", "Leah"],
#         #     frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#         #     # id: {:sidebar, :low_pane, "Open"})
#         #     id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

#         |> Scenic.Graph.modify(:sidebar_search_results, &Scenic.Primitives.update_opts(&1, hidden: false))

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#          {:noreply, new_scene}
#     end

#     def handle_cast({:switch_mode, :normal}, scene) do
#         IO.puts "GOING INTO NORMAL MODE"
#         new_graph = scene.assigns.graph
#         # |> Scenic.Graph.delete(:sidebar_tabs)
#         # |> Scenic.Graph.delete(:sidebar_lowpane)
#         # |> Sidebar.OpenTidBits.add_to_graph(%{
#         #     open_tidbits: ["Luke", "Leah"],
#         #     frame: sidebar_open_tidbits_frame(scene.assigns.frame)},
#         #     # id: {:sidebar, :low_pane, "Open"})
#         #     id: :sidebar_lowpane) # they all use this save id, so we can just delete this every time

#         |> Scenic.Graph.modify(:sidebar_search_results, &Scenic.Primitives.update_opts(&1, hidden: true))

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> push_graph(new_graph)

#          {:noreply, new_scene}
#     end

#     def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
#         new_scene = scene
#         |> assign(frame: f)
#         |> render_push_graph()
        
#         {:reply, :ok, new_scene}
#     end



#     #NOTE - you know, this is really the only thing that changes... all
#     #       the above is Boilerplate

#     # def render(scene) do
#     #     scene |> Draw.background(:light_blue)
#     # end

#     # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
#     #     new_scene = scene
#     #     |> assign(frame: f)
#     #     |> render_push_graph()
        
#     #     {:reply, :ok, new_scene}
#     # end
# end
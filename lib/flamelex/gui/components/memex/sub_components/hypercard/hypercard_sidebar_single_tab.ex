defmodule Flamelex.GUI.Component.Memex.HyperCard.OneTab do #TODO SingleTab
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @component_id :hypercard_tagsbox
    @background_color :red

    def validate(%{frame: %Frame{} = _f, label: l} = data) when is_bitstring(l) do
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


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, color: color, label: l}} = scene) do
        text_color = Enum.random([:black, :white, :red, :purple, :brown])
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: @component_id,
                    fill: color,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})
            |> Scenic.Primitives.text(l,
                    font: :ibm_plex_mono,
                    translate: {
                        frame.top_left.x+10, # 10 for left hand margin
                        frame.top_left.y+(frame.dimensions.height/2)+10}, # text draws from bottom-left corner??
                    font_size: 18,
                    fill: text_color)

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



    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

    def handle_input({:cursor_button, {:btn_left, 0, [], coords}}, _context, scene) do
       bounds = Scenic.Graph.bounds(scene.assigns.graph) 
       if coords |> inside?(bounds) do
         Logger.debug "You clicked inside the tab: #{scene.assigns.label}"
         #TODO here we need to throw the event "up" into SideBar to handle
         #TODO is this still supported? If not, Scenic docs need updating...
        #  {:cont, {:tab_click, scene.assigns.label}, scene}
        # GenServer.cast(Flamelex.GUI.Component.Memex.SideBar, {:open_tab, scene.assigns.label})
        {:gui_component, Flamelex.GUI.Component.Memex.HyperCard.Sidebar.LowerPane, :lower_pane}
        |> ProcessRegistry.find!()
        |> GenServer.cast({:open_tab, scene.assigns.label})

         {:noreply, scene}
       else
        #  IO.puts "DID NOT CLICK ON A TAB"
         {:noreply, scene}
       end
    end

    def handle_input(input, _context, scene) do
        #IO.puts "TABS GOT INPUT #{inspect input}, context: #{inspect context}"
        {:noreply, scene}
    end

    # https://hexdocs.pm/scenic/0.11.0-beta.0/Scenic.Graph.html#bounds/1
    # def inside?({x, y}, {left, right, top, bottom} = _bounds) do
    def inside?({x, y}, {left, bottom, right, top} = _bounds) do #TODO update the docs in Scenic itself
        # remember, if y > top, if top is 100 cursor might be 120 -> in the box ??
        # top <= y and y <= bottom and left <= x and x <= right
        bottom <= y and y <= top and left <= x and x <= right
    end

end
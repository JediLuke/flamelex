defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SingleResult do
    use Flamelex.GUI.ComponentBehaviour
    alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar
    use ScenicWidgets.ScenicEventsDefinitions
    
    #TODO use LayoutItem??

    def request_input(scene) do
        request_input(scene, [:cursor_pos, :cursor_button])
    end

    def render(graph, %{state: %{title: text}, frame: frame}) do
        graph
        |> Scenic.Primitives.rect(frame.size, fill: :blue, t: {10, -32}, id: :background)
        |> Scenic.Primitives.text(text, t: {10, 0})
    end

    def handle_input({:cursor_pos, {x, y} = coords}, _context, scene) do
        bounds = Scenic.Graph.bounds(scene.assigns.graph)

        new_graph =
            if coords |> inside?(bounds) do
                scene.assigns.graph
                |> Scenic.Graph.modify(:background, &Scenic.Primitives.update_opts(&1, fill: :green))
            else
                scene.assigns.graph
                |> Scenic.Graph.modify(:background, &Scenic.Primitives.update_opts(&1, fill: :blue))
            end

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    def handle_input({:cursor_button, {:btn_left, 0, [], coords}}, _context, scene) do
        bounds = Scenic.Graph.bounds(scene.assigns.graph)

        if coords |> inside?(bounds) do
            #TODO - so ideally, we should treat buttons clicks as the same
            #       as user input - it should get routed to the RadixFluxus,
            #       parsed in the context of the global & local state, etc...
            Flamelex.API.MemexWrap.open(scene.assigns.state)

            Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchBox
            # |> ProcessRegistry.find!()
            |> GenServer.cast(:deactivate)

            {:gui_component, Flamelex.GUI.Component.Memex.HyperCard.Sidebar.LowerPane, :lower_pane}
            |> ProcessRegistry.find!()
            |> GenServer.cast({:open_tab, "unknown"})
        end

        {:noreply, scene}
    end

    def handle_input({:cursor_button, _otherwise}, _context, scene) do
        {:noreply, scene}
    end

        # def inside?({x, y}, {left, bottom, right, top} = _bounds) do #TODO update the docs in Scenic itself 
    def inside?({x, y}, {left, top, right, bottom} = _bounds) do #TODO update the docs in Scenic itself 
        # remember, if y > top, if top is 100 cursor might be 120 -> in the box
        # top <= y and y <= bottom and left <= x and x <= right
        x >= left and y >= top and x <= right and y <= bottom
    end
end
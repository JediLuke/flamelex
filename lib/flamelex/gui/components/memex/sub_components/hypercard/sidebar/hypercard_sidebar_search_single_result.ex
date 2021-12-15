defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SingleResult do
    use Flamelex.GUI.ComponentBehaviour
    alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar
    use Flamelex.GUI.ScenicEventsDefinitions
    
    #TODO use LayoutItem??

    def request_input(scene) do
        request_input(scene, [:cursor_pos])
    end

    def render(graph, %{state: %{text: text}, frame: frame}) do
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

        # def inside?({x, y}, {left, bottom, right, top} = _bounds) do #TODO update the docs in Scenic itself 
    def inside?({x, y}, {left, top, right, bottom} = _bounds) do #TODO update the docs in Scenic itself 
        # remember, if y > top, if top is 100 cursor might be 120 -> in the box
        # top <= y and y <= bottom and left <= x and x <= right
        x >= left and y >= top and x <= right and y <= bottom
    end
end
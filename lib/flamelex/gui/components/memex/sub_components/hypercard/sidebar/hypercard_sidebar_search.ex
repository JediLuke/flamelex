defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchBox do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard.OneTab

    @component_id :hypercard_sidebar_tabs
    @background_color :antique_white

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
         |> assign(mode: :inactive)
        |> render_push_graph()
    
        request_input(init_scene, [:cursor_button])

        {:ok, init_scene}
    end

    # def re_render(scene) do
    #     GenServer.call(__MODULE__, {:re_render, scene})
    # end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{frame: %Frame{top_left: %{x: x, y: y}} = frame}} = scene) do
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                id: @component_id,
                fill: @background_color,
                scissor: {frame.dimensions.width, frame.dimensions.height},
                stroke: {1, :black},
                translate: {
                    frame.top_left.x,
                    frame.top_left.y })
                |> render_magnifying_glass_icon(frame)
                |> Scenic.Components.text_field("Search...", id: :search_field, translate: {x+42,y+5})

             end, [])

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render_magnifying_glass_icon(graph, %{top_left: %{x: x, y: y}, dimensions: %{ width: w, height: h}}) do
       graph 
       |> Scenic.Primitives.circle(10,
                stroke: {4, :grey},
                translate: {x+17, y+17})
        |> Scenic.Primitives.line({{x+25, y+25}, {x+35, y+35}},
                id: :sidebar_line,
                stroke: {4, :grey})
    end

    # def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
    #     new_graph = graph
    #     |> Scenic.Graph.delete(@component_id)
    #     |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #                 id: @component_id,
    #                 fill: @background_color,
    #                 translate: {
    #                     frame.top_left.x,
    #                     frame.top_left.y})

    #     scene
    #     |> assign(graph: new_graph)
    # end
    
    def handle_input({:cursor_button, {:btn_left, 0, [], coords}}, _context, %{assigns: %{mode: :inactive}} = scene) do
        Logger.debug "#{__MODULE__} recv'd :btn_left"
       bounds = Scenic.Graph.bounds(scene.assigns.graph) 
       IO.inspect bounds
       IO.inspect coords
       if coords |> inside?(bounds) do
        #  GenServer.cast(Flamelex.GUI.Component.Memex.SideBar, {:switch_mode, :search})
          
         {:noreply, scene |> assign(mode: :search)}
       else
         {:noreply, scene}
       end
    end


    def handle_input(input, _context, scene) do
        #IO.puts "TABS GOT INPUT #{inspect input}, context: #{inspect context}"
        {:noreply, scene}
    end

    def handle_event({:value_changed, :search_field, value}, _context, scene) do
        # IO.puts "OT AN EVENT #{inspect event}"
        {:noreply, scene}
    end


    # def inside?({x, y}, {left, bottom, right, top} = _bounds) do #TODO update the docs in Scenic itself 
    def inside?({x, y}, {left, top, right, bottom} = _bounds) do #TODO update the docs in Scenic itself 
        # remember, if y > top, if top is 100 cursor might be 120 -> in the box
        top <= y and y <= bottom and left <= x and x <= right
    end
end
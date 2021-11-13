defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.MoreFeatures do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @component_id :sidebar_more_features
    @background_color :black

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


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame}} = scene) do
        {new_graph, button_bounds} =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width-10, frame.dimensions.height-10},
                    id: @component_id,
                    fill: @background_color,
                    translate: {
                        frame.top_left.x+5,
                        frame.top_left.y+5})
            |> render_rando_tidbit_button(frame)

        scene
        |> assign(graph: new_graph)
        |> assign(button_bounds: button_bounds)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Graph.delete(:rando_tidbit_button)
        |> Scenic.Primitives.rect({frame.dimensions.width-10, frame.dimensions.height-10},
                    id: @component_id,
                    fill: @background_color,
                    translate: {
                        frame.top_left.x+5,
                        frame.top_left.y+5})
        |> render_rando_tidbit_button(frame)

        scene
        |> assign(graph: new_graph)
    end

    def handle_input({:cursor_button, {:btn_left, 0, [], coords}}, _context, scene) do
        #Logger.debug "#{__MODULE__} recv'd :btn_left"
        # [btn] = Scenic.Graph.get(scene.assigns.graph, :rando_tidbit_button)
        # ic btn
    #    bounds = Scenic.Graph.bounds(scene.assigns.graph) 
    #    ic bounds
    ic scene.assigns.button_bounds
    ic coords
       if coords |> inside?(scene.assigns.button_bounds) do
        IO.puts "CLICKED RANDO TIDBIT"
        # GenServer.cast(Flamelex.GUI.Component.Memex.SideBar, {:open_tab, scene.assigns.label})
         {:noreply, scene}
       else
        IO.puts "OUTSIDE!??"
         {:noreply, scene}
       end
    end

    def inside?({x, y}, {left, bottom, right, top} = _bounds) do #TODO update the docs in Scenic itself 
            # remember, if y > top, if top is 100 cursor might be 120 -> in the box
        top <= y and y <= bottom and left <= x and x <= right
    end

    def handle_input(input, _context, scene) do
        #IO.puts "TABS GOT INPUT #{inspect input}, context: #{inspect context}"
        {:noreply, scene}
    end

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

    def render_rando_tidbit_button(graph, frame) do
        roundedness = 8
        text_margin = 10
        text_size = 18
        button_width = 200
        button_height = 40
        margin = 10
        new_graph = graph
        |> Scenic.Primitives.rounded_rectangle({
            button_width,
            button_height,
                roundedness},
                id: :rando_tidbit_button,
                fill: :orange,
                translate: {frame.top_left.x+margin, frame.top_left.y+margin})
        |> Scenic.Primitives.text("Random TidBit",
                font: :ibm_plex_mono,
                translate: {frame.top_left.x+margin+text_margin, frame.top_left.y+text_margin+text_size+margin}, # text draws from bottom-left corner??
                font_size: text_size,
                fill: :blue)

        left = frame.top_left.x+margin
        bottom = frame.top_left.y+margin+button_height
        right = frame.top_left.x+margin + button_width
        top = frame.top_left.y+margin
        {new_graph, {left, bottom, right, top}}
    end


end
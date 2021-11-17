defmodule Flamelex.GUI.Component.Memex.HyperCardTitle do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @component_id :hypercard_title
    @background_color :yellow

    @font_size 28

    def validate(%{frame: %Frame{} = _f, text: t} = data) when is_bitstring(t) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end


    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration
        # Process.register(self(), :hypercard_title) #TODO this is something that the old use Component system had - inbuilt process registration

        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

        init_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
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


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, text: text}} = scene) do
        buffer = 10
        new_graph =
            Scenic.Graph.build()
            |> common_render(frame, text)

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, text: text}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Graph.delete(:hypercard_title_text)
        |> common_render(frame, text)

        scene
        |> assign(graph: new_graph)
    end

    def char_width do
        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        FontMetrics.width("a", @font_size, metrics)
    end


    def common_render(graph, frame, text) do
        frame_width = frame.dimensions.width
        ic frame_width
        num_chars = frame_width/char_width()
        ic num_chars
        #35 chars wide, for 24 ibm plex mono

        frame_height = frame.dimensions.height


        buffer = 10
        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                     id: @component_id,
                     fill: @background_color,
                     scissor: {frame.dimensions.width, frame.dimensions.height})
                     # translate: {
                     #     frame.top_left.x,
                     #     frame.top_left.y})
            |> Scenic.Primitives.text(text,
                     id: :hypercard_title_text,
                     font: :ibm_plex_mono,
                     # scissor: {frame.dimensions.width, frame.dimensions.height},
                     # translate: {frame.top_left.x+buffer, frame.top_left.y+font_size+(2*buffer)}, # text draws from bottom-left corner??
                     translate: {buffer, @font_size+buffer}, # text draws from bottom-left corner??
                     font_size: @font_size,
                     fill: :black)
         end,
         id: :block,
         # scissor: {frame.dimensions.width, frame.dimensions.height},
         translate: {frame.top_left.x, frame.top_left.y})
         # scissor: {frame.dimensions.width, frame.dimensions.height})
    end


    def handle_call({:update, %{tidbit: t}}, _from, scene) do
        new_scene = scene
        # |> assign(frame: f)
        |> assign(text: t.title)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

end
defmodule Flamelex.GUI.Component.Memex.HyperCardTitle do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @component_id :hypercard_title
    @background_color :yellow

    def validate(%{frame: %Frame{} = _f, text: t} = data) when is_bitstring(t) do
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
        font_size = 28
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: @component_id,
                    fill: @background_color,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})
            |> Scenic.Primitives.text(text,
                    id: :hypercard_title_text,
                    font: :ibm_plex_mono,
                    translate: {frame.top_left.x+buffer, frame.top_left.y+font_size+(2*buffer)}, # text draws from bottom-left corner??
                    font_size: font_size,
                    fill: :black)

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, text: text}} = scene) do
        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Graph.delete(:hypercard_title_text)
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

end
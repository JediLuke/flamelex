defmodule Flamelex.GUI.Component.Memex.CollectionsPane do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        IO.puts "VALIDDDDDDDDDDDDDDDD"
        # raise "here we should use proper Scenic validation, but - you forgot to use frames"
        {:error, "missing frame"}
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

    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame}} = scene) do
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: :collections_bg,
                    fill: :pink,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do

        # IO.inspect graph

        # bg = Scenic.Graph.get(graph, :collections_bg)
        # IO.inspect bg, label: "BACKROUND"
        new_graph = graph
        |> Scenic.Graph.delete(:collections_bg)
        |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: :collections_bg,
                    fill: :pink,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})
        # |> Scenic.Graph.modify(:collections_bg, )
        # Logger.debug "#{__MODULE__} re-rendering..."
        # scene |> Draw.background(:light_pink)

        # width  = frame.dimensions.width + 1 #TODO need width +1 here for some quirky reason of Scenic library
        # height = frame.dimensions.height
        scene
        |> assign(graph: new_graph)
    
        # new_graph =
        #   graph
        #   |> Scenic.Primitives.rect({width, height}, fill: color, translate: {frame.top_left.x, frame.top_left.y})
    
        # scene |> put_graph(new_graph)


    end

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        IO.inspect f, label: "NEW GRAME"
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

end
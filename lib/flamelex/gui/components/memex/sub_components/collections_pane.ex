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
        |> assign(graph: Scenic.Graph.build())
        |> render_push_graph()
    

        {:ok, init_scene}
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end

    def render(scene) do
        IO.puts "SHOULD BE ADDING THE BACKGROUND FOR COLLECTIONS LIST"
        scene |> Draw.background(:light_pink)
    end
end
defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

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
        |> assign(graph: Scenic.Graph.build())
        |> render_push_graph()
    

        {:ok, init_scene}
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end

    #NOTE - you know, this is really the only thing that changes... all
    #       the above is Boilerplate

    def render(scene) do
        ##TODO next steps

        # we have the hypercard component - we want to really robustify
        # that component
        #
        # then we want to be able to get the sidebar happening with "recent",
        # "open" etc.
        #
        # then we want to be able to edit TidBits
        #
        # Scrolling doesn't even have to come till like last, we can just
        # flick through left/right
        scene
    end

    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        Logger.debug "#{__MODULE__} re-rendering..."
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end
end
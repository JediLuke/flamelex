defmodule Flamelex.GUI.Memex.Layout do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
    
        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        init_graph = Scenic.Graph.build()
        |> ScenicWidgets.TestPattern.add_to_graph(%{})
  
        new_scene = init_scene
        |> assign(graph: init_graph)
        |> push_graph(init_graph)
  
        {:ok, new_scene}
      end

end
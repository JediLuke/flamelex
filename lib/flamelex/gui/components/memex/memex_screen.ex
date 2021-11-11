defmodule Flamelex.GUI.Component.MemexScreen do
   use Scenic.Component
   use Flamelex.ProjectAliases
   require Logger


   def validate(%{frame: %Frame{} = _f} = data) do
      Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end


   def init(scene, params, opts) do
      Logger.debug "#{__MODULE__} initializing..."
      IO.inspect scene, label: "MEMEX"
      # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration
  
      # request_input(new_scene, [:cursor_pos, :cursor_button])
      # Flamelex.Utils.PubSub.subscribe(topic: :gui_update_bus)

      # new_graph = DefaultGUI.draw(state)
      # GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
      # {:noreply, %{state|graph: new_graph}}

      # {:ok, state, {:continue, :draw_default_gui}}

      # new_graph = 
      #    render(scene, params)
      merged_scene = %{scene|assigns: scene.assigns |> Map.merge(params)}
      IO.inspect merged_scene

      # new_scene =
      #    scene
      #    |> assign(graph: new_graph)
      #    |> push_graph(new_graph)

      {:ok, scene}
    end

end
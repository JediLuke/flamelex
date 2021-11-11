defmodule Flamelex.GUI.Component.MemexScreen do
   use Scenic.Component
   use Flamelex.ProjectAliases
   require Logger
   alias Flamelex.GUI.Component.Memex.{CollectionsPane,
                                       StoryRiver, SideBar}

   def validate(%{frame: %Frame{} = _f} = data) do
      Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end


   def init(scene, params, opts) do
      Logger.debug "#{__MODULE__} initializing..."
      Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration
  
      # request_input(new_scene, [:cursor_pos, :cursor_button])
      # Flamelex.Utils.PubSub.subscribe(topic: :gui_update_bus)

      # new_graph = DefaultGUI.draw(state)
      # GenServer.cast(Flamelex.GUI.RootScene, {:redraw, new_graph})
      # {:noreply, %{state|graph: new_graph}}

      # {:ok, state, {:continue, :draw_default_gui}}

      # new_graph = 
      #    render(scene, params)

      merged_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)}
         |> assign(graph: Scenic.Graph.build())
         |> render_push_graph()

      # new_scene =
      #    scene
      #    |> assign(graph: new_graph)
      #    |> push_graph(new_graph)

      {:ok, merged_scene}
    end

   @skip_log true

   def render_push_graph(%Scenic.Scene{assigns: %{graph: %Scenic.Graph{} = _g}} = scene) do
      #NOTE: On the flip side, we are (potentially? Maybe Scenic optimizes?)
      #      re-drawing the entire graph for every mouse-movement...
      case Wormhole.capture(__MODULE__, :render, [scene], skip_log: @skip_log) do
        {:ok, %Scenic.Scene{assigns: %{graph: %Scenic.Graph{} = _g}} = new_scene} ->
          new_scene |> push_graph(new_scene.assigns.graph)
        {:error, reason} ->
          Logger.error "#{__MODULE__} unable to render Scene! #{inspect reason}"
          scene # make no changes
      end
   end

   # def render_push_graph(scene) do
   #    scene
   #    |> assign(graph: Scenic.Graph.build())
   #    |> render_push_graph()
   # end


   ## render


   #NOTE - render gets a scene, & must return a scene!
   def render(scene) do

      scene
      |> Draw.background()
      |> add_collections_pane(%{frame: left_quadrant(scene.assigns.frame)})
      |> Draw.test_pattern()

      # new_graph =
      # Scenic.Graph.build()
      # # |> Draw.background(:light_green)
      # # |> Draw.border()
      # # |> CollectionsPane.add_to_graph(%{}, id: :collections_pane)
      # # |> StoryRiver.add_to_graph(%{}, id: :story_river)
      # # |> SideBar.add_to_graph(%{}, id: :memex_sidebar)
      # |> Draw.test_pattern(scene)

      # scene
      # |> assign(graph: new_graph)
   end

   def add_collections_pane(scene, data) do
      new_graph = scene.assigns.graph
      |> CollectionsPane.add_to_graph(data)

      %{scene|assigns: scene.assigns |> Map.merge(%{graph: new_graph})}
   end

   def left_quadrant(%{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}} = frame) do
     Frame.new(top_left: {x, y}, dimensions: {w/4, h})
   end
end
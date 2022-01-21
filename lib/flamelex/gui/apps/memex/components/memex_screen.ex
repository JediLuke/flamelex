defmodule Flamelex.GUI.Component.MemexScreen do
   use Scenic.Component
   use Flamelex.ProjectAliases
   require Logger
   alias Flamelex.GUI.Component.Memex.{CollectionsPane,
                                       StoryRiver, SideBar, SecondSideBar}

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
      # GenServer.call(Flamelex.GUI.RootScene, {:redraw, new_graph})
      # {:noreply, %{state|graph: new_graph}}

      # {:ok, state, {:continue, :draw_default_gui}}

      # new_graph = 
      #    render(scene, params)

      new_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # just dump params straight into assigns
         |> assign(graph: Scenic.Graph.build())
         |> assign(first_render?: true) # First time we have to "boot" the Components, after that we just update them
         |> render_push_graph()

      request_input(new_scene, :viewport)

      # new_scene =
      #    scene
      #    |> assign(graph: new_graph)
      #    |> push_graph(new_graph)

      {:ok, new_scene}
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

   def handle_input({:viewport, {:reshape, {new_width, new_height} = new_dimensions}}, context, scene) do # e.g. of new_dimensions: {1025, 818}
      Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

      new_scene = scene
      |> assign(frame: Frame.new(
                         pin: {0, 0},
                         orientation: :top_left,
                         size: {new_width, new_height},
                         #TODO deprecate below args
                         top_left: Coordinates.new(x: 0, y: 0), # this is a guess
                         dimensions: Dimensions.new(width: new_width, height: new_height)))
      |> render_push_graph()
      {:noreply, scene}
   end

   def handle_input({:viewport, whatever}, context, scene) do # e.g. of new_dimensions: {1025, 818}
      #Logger.debug "ignoring some input from the :viewport - #{inspect whatever}"
      {:noreply, scene}
   end

   # def render_push_graph(scene) do
   #    scene
   #    |> assign(graph: Scenic.Graph.build())
   #    |> render_push_graph()
   # end


   ## render


   def render(%{assigns: %{first_render?: true}} = scene) do
      Logger.debug "First render of the Memex Screen..."
      scene
      # |> Draw.background()
      #IDEA: Instead of going top-down "I'm the screen, this is your frame"
      #      we give each component just knowledge of their percentage of the viewport!!
      #      Better to give these intructions & have component make it's own Frame
      |> add_collections_pane(%{frame: left_quadrant(scene.assigns.frame)})
      |> Draw.test_pattern()
      |> add_story_river(%{frame: mid_section(scene.assigns.frame)})
      |> add_sidebar(%{frame: right_quadrant(scene.assigns.frame)})
      |> assign(first_render?: false)
   end

   #NOTE - render gets a scene, & must return a scene!
   def render(scene) do
      Logger.debug "Re-rendering the Memex Screen..."

      #NOTE: This ONLY works for re-rendering updates. We need a more robust
      #      and general way of "pushing down" to child components
      #
      #      eex templates may be the best answer for this
      # scene |> Draw.background()
      CollectionsPane.re_render(%{frame: left_quadrant(scene.assigns.frame)})
      GenServer.call(StoryRiver, {:re_render, %{frame: mid_section(scene.assigns.frame)}})
      GenServer.call(SideBar, {:re_render, %{frame: right_quadrant(scene.assigns.frame)}})

      scene


      # |> update_sub_components()
      # |> update_collections_pane(%{frame: left_quadrant(scene.assigns.frame)})
      # |> update_story_river(%{frame: mid_section(scene.assigns.frame)})
      # |> update_sidebar(%{frame: right_quadrant(scene.assigns.frame)})
      # ic scene


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

   def add_sidebar(scene, %{frame: frame}) do
      #TODO here, we can experiment - we want to switch out old sidebar, for TidBar
      new_graph = scene.assigns.graph
      # |> SideBar.add_to_graph(data)
      |> SecondSideBar.mount(%{ref: :second_sidebar, frame: frame, state: %{}})

      %{scene|assigns: scene.assigns |> Map.merge(%{graph: new_graph})}
   end

   def add_story_river(scene, data) do
      new_graph = scene.assigns.graph
      |> StoryRiver.add_to_graph(data)

      %{scene|assigns: scene.assigns |> Map.merge(%{graph: new_graph})}
   end

   def left_quadrant(%{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}} = frame) do
      Frame.new(top_left: {x, y}, dimensions: {w/4, h})
   end

   def right_quadrant(%{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}} = frame) do
     Frame.new(top_left: {x+((3/4)*w), y}, dimensions: {w/4, h})
   end

   def mid_section(%{top_left: %Coordinates{x: x, y: y}, dimensions: %Dimensions{width: w, height: h}} = frame) do
      one_quarter_page_width = w/4
      Frame.new(top_left: {x+one_quarter_page_width, y}, dimensions: {w/2, h})
    end
end
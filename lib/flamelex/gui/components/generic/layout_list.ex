defmodule Flamelex.GUI.Component.LayoutList do
  use Scenic.Component
  use Flamelex.ProjectAliases
  require Logger

  # has input params: Frame, & layout type (axis)
  # then, renders a list of components (another input) with their
  # params (from input), inside this frame-based component which keeps
  # track of how large each rendered, and is able to add/remove them
  # from the screen aswell. We also handle scroll here.

  #NOTE - here's the idea - we have a group that we can add &
  #       subtract to, and a "render list" - we render an item,
  #       it calculates it's own height/length, and the story river
  #       (or whatever) stashes it inside itself as "unrendered" or
  #       something. Then, the first component loads, casts back
  #       "hey, I rendeered, I'm xyz long/high" - this will trigger
  #       the rendering of the next component, and we have all the
  #       data we need!


  # def render(list of components)
  # def add / remove


  def validate(%{
        id: _id,
        frame: %Frame{} = _f,
        components: c,
        layout: l, #NOTE: Eventually, we want to have this available as "offset" aswell, for e.g. ManuBars - and plz blog this out one day!
        scroll: true,
      } = data) when l in [:flex_grow] and is_list(c) do
    Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    {:ok, data}
  end

  def validate(_data) do
      {:error, "This component must be passed a %Frame{}"}
  end

  def init(scene, params, opts) do
    Logger.debug "#{__MODULE__} initializing..."

    state = %{
      # first_render?: true, #NOTE: We can do everything for the "first render" in the init/3 function
      active_components: [], # we haven't rendered any yet, so none are active
      render_queue: params.components, # we will go through this list very soon & render them...
      scroll: {0, 0},
    }

    #NOTE- make the container group, give it translation etc, just don't add any components yet
    new_graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
           graph
         end, [
            #NOTE: We will scroll this pane around later on, and need to
            #      add new TidBits to it with Modify
            id: :river_pane, # Scenic required we register groups/components with a name
            translate: state.scroll
         ])

    new_scene = scene
    |> assign(state: state)
    |> assign(graph: new_graph)
    |> push_graph(new_graph)

    GenServer.cast(self(), :render_next_component) # trigger rendering of our (potential) backlog of components to render!
    # remember, they need to render "one at a time (yuck) - (or do they??) to get their positions"

    request_input(new_scene, [:cursor_scroll])

    {:ok, new_scene}
  end


    # def render_push_graph(scene) do
    #   new_scene = render(scene) # updates the graph
    #   new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    # end

    def handle_input({:cursor_scroll, {{_x_scroll, y_scroll} = delta_scroll, coords}}, _context, scene) do
      Logger.warn "#{__MODULE__} getting :scroll"
      # Logger.debug "Handling right scrolling - "

      fast_scroll = {0, 3*y_scroll}
      new_cumulative_scroll =
          Scenic.Math.Vector2.add(scene.assigns.scroll, fast_scroll)

      new_graph = scene.assigns.graph
          |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: new_cumulative_scroll))

      # new_state = scene.assigns
      #     |> Map.merge(%{scroll: new_cumulative_scroll})

      # # new_graph = render(state, first_render?: true)
      new_scene = scene
      |> assign(graph: new_graph)
      # |> assign(state: new_state)
      |> push_graph(new_graph)

      {:noreply, scene |> assign(scroll: new_cumulative_scroll)}
  end

  # Whenever a component successfully renders, it uses this to track how
  # big it is
  # def handle_cast({:component_callback, id, %{bounds: bounds} = data}, scene) do
  #   # this callback is received when a component boots successfully -
  #   # it register itself to this component (parent-child relationship,
  #   # which ought to be able to handle props aswell!) including it's
  #   # own size (since I want TidBits to grow organizally based on their
  #   # size, and only wrap/clip in the most extreme circumstancses and/or
  #   # boundary conditions)
  #   IO.puts "#{inspect id} HEIGHT: #{inspect bounds}"
  #   ic scene

  #   new_state = scene.assigns.state
  #   |> add_rendered_component({id, bounds})

  #   GenServer.cast(self(), :render_next_component)

  #   #TODO
  #   # new_graph = scene.assigns.graph
  #   # |> 

  #   new_scene = scene
  #   |> assign(state: new_state)
  #   # |> assign(open_tidbits: [{id, bounds}])

  #   # now, this scene will be able to use this data to render the
  #   # next TidBit in place!

  #   {:noreply, scene}
  # end

end
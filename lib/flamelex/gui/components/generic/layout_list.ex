defmodule Flamelex.GUI.Component.LayoutList do
  use Scenic.Component
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.GUI.Component.Memex.HyperCard

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
        components: compnts,
        layout: l, #NOTE: Eventually, we want to have this available as "offset" aswell, for e.g. ManuBars - and plz blog this out one day!
        scroll: true,
      } = data) when l in [:flex_grow] and is_list(compnts) do
        
    # Enum.each(compnts, fn %{module: mod, params: p, opts: o} = p ->
    #   Logger.debug "valid component: #{inspect p}"
    # end)
        
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
      render_queue: [] = params.components, # we will go through this list very soon & render them...
      scroll: {0, 0},
      acc_height: 0,
    }

    Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

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
    |> assign(frame: params.frame)
    |> assign(graph: new_graph)
    |> push_graph(new_graph)

    GenServer.cast(self(), :render_next_component) # trigger rendering of our (potential) backlog of components to render!
    # remember, they need to render "one at a time (yuck) - (or do they??) to get their positions"

    request_input(new_scene, [:cursor_scroll])

    {:ok, new_scene}
  end


      # def handle_cast({:add_tidbit, tidbit}, %{assigns: %{open_tidbits: ot}} = scene) when is_list(ot) do
    #     IO.puts "YES ADD TIDBIT"

    #     #TODO hack
    #     # [{_id, {left, bottom, right, top} = bounds}] = ot
    #     [{_id, {left, top, right, bottom} = bounds}] = ot

    #     new_graph = 
    #     scene.assigns.graph
    #     # |> Scenic.Graph.modify(:river_pane, fn group ->
    #     #         IO.inspect group, label: "FETCHED RIVER PANE"
    #     # end)
    #     |> Scenic.Graph.add_to(:river_pane, fn graph ->
    #             IO.inspect graph, label: "FETCHED RIVER PANE - inside ADD TO"

    #             graph
    #             |> HyperCard.add_to_graph(%{
    #                 # frame:  Frame.new(top_left: {frame.top_left.x+bm, existing_graph_height+bm}, dimensions: {frame.dimensions.width-(2*bm), 700}),
    #                 frame:  Frame.new(top_left: {bottom+15, left}, dimensions: {400, 400}),
    #                 # frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #                 tidbit: tidbit })

    #     end)
        
    #     # raise "this needs to be converted over to the new system"
    #     # frame = scene.assigns.frame

    #     # new_tidbit_list = scene.assigns.open_tidbits ++ [tidbit]
    #     # # new_graph = scene.assigns.graph
    #     # # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #     # # # id: :story_river,
    #     # # fill: :blue,
    #     # # translate: {
    #     # #     frame.top_left.x,
    #     # #     frame.top_left.y+600 })

    #     # # new_graph = scene.assigns.graph
    #     # # |> HyperCard.add_to_graph(%{
    #     # #         frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #     # #         tidbit: tidbit },
    #     # #         id: :hypercard,
    #     # #         t: scene.assigns.scroll)

    #     # #TODO modify :river_pane - HERE

    #     # new_graph = scene.assigns.graph
    #     # |> Scenic.Graph.delete(:river_pane)
    #     # |> common_render(scene.assigns.frame, new_tidbit_list, scene.assigns.scroll)
    #     # # |> Scenic.Graph.modify(:river_pane, fn group ->
    #     # #     graph
    #     # #     |> HyperCard.add_to_graph(%{
    #     # #             frame: second_hypercard_frame(frame), # calculate hypercard based of story_river
    #     # #             tidbit: tidbit })
    #     # #             # id: :hypercard,
    #     # #             # t: scroll)
        
    #     # # end)
    #     # #     |> Scenic.Primitives.group(fn graph ->
    #     # #     graph
    #     # #     |> HyperCard.add_to_graph(%{
    #     # #             frame: hypercard_frame(frame), # calculate hypercard based of story_river
    #     # #             tidbit: t })
    #     # #             # id: :hypercard,
    #     # #             # t: scroll)
    #     # # end, [
    #     # #     #NOTE: We will scroll this pane around later on, and need to
    #     # #     #      add new TidBits to it with Modify
    #     # #     id: :river_pane, # Scenic required we register groups/components with a name
    #     # #     translate: scroll
    #     # # ])
        
    #     # # &text(&1, "Updated Text 3") )

    #     new_scene = scene
    #     |> assign(graph: new_graph)
    #     # |> assign(open_tidbits: newtidbit_list)
    #     |> push_graph(new_graph)

    #     {:noreply, new_scene}
    # end




  def handle_call({:add_tidbit, tidbit}, _from, scene) do
    #TODO note this is pretty arbitrary!! What if we don't want to add a HyperCard??
    new_item = {HyperCard, tidbit, []}

    new_state = scene.assigns.state
    new_state = %{new_state|render_queue: new_state.render_queue ++ [new_item]}

    new_scene = scene
    |> assign(state: new_state)

    GenServer.cast(self(), :render_next_component)
    
    {:reply, :ok, new_scene}
  end

  # def handle_call({:add_tidbit, tidbit}, _from, %{assigns: %{state: state}} = scene) do
  #   #TODO note - I cant handle adding more than  tidbit yet, so that's why the above matches on active_components: [], and this is a catchall
  #   Logger.warn "Trying to add tidbit, bad bad"
  #   IO.inspect state.active_components
  #   {:reply, :ok, scene}
  # end

  def handle_cast(:render_next_component, %{assigns: %{state: %{render_queue: []}}} = scene) do
    Logger.debug "#{__MODULE__} ignoring a request to render a component, there's nothing to render"
    {:noreply, scene}
  end

  def handle_cast(:render_next_component, scene = %{assigns: %{state: %{
                    #  active_components: [],
                     acc_height: acc_height,
                     render_queue: [c|rest]}}}) do
    Logger.debug "Attempting to render an additional component in the LayoutList..."

    margin_buf = 50 # this is how much margin we render around each HyperCard
    {HyperCard, tidbit, opts} = c #TODO lol

    frame = scene.assigns.frame
    state = scene.assigns.state
    new_state = %{state | render_queue: rest}

    new_graph = scene.assigns.graph
    |> Scenic.Graph.add_to(:river_pane, fn graph ->
          args = %{
            tidbit: tidbit,
            top_left: {frame.top_left.x+margin_buf, frame.top_left.y+margin_buf+acc_height},
            width: frame.dimensions.width-(2*margin_buf) # got to take off the margun_buf from each side...
          }
          Kernel.apply(HyperCard, :add_to_graph, [graph, args, opts])
          # |> HyperCard.add_to_graph(%{
          #     top_left: {},
          #     width: {},
          #     length: :flex,
          #     # frame:  Frame.new(top_left: {frame.top_left.x+bm, existing_graph_height+bm}, dimensions: {frame.dimensions.width-(2*bm), 700}),
          #     # frame:  Frame.new(top_left: {bottom+15, left}, dimensions: {400, 400}),
          #     # frame: hypercard_frame(frame), # calculate hypercard based of story_river
          #     tidbit: tidbit })
    end)

    # then, riht at the end, call itself again until there's no render queue components (!?!?)
    # GenServer.cast(self(), :render_next_component)

    new_scene = scene
    |> assign(graph: new_graph)
    |> assign(state: new_state)
    |> push_graph(new_graph)

    {:noreply, new_scene}
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
          Scenic.Math.Vector2.add(scene.assigns.state.scroll, fast_scroll)

      new_graph = scene.assigns.graph
          |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: new_cumulative_scroll))

      # new_state = scene.assigns
      #     |> Map.merge(%{scroll: new_cumulative_scroll})

      # # new_graph = render(state, first_render?: true)
      new_scene = scene
      |> assign(graph: new_graph)
      # |> assign(state: new_state)
      |> push_graph(new_graph)

      state = scene.assigns.state
      new_state = %{state|scroll: new_cumulative_scroll}

      {:noreply, scene |> assign(state: new_state)}
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

  def handle_cast({:component_height, id, bounds}, %{assigns: %{state: state}} = scene) do
      # this callback is received when a component boots successfully -
      # it register itself to this component (parent-child relationship,
      # which ought to be able to handle props aswell!) including it's
      # own size (since I want TidBits to grow organizally based on their
      # size, and only wrap/clip in the most extreme circumstancses and/or
      # boundary conditions)
      # Logger.emergency "WERE GETTING CALLBACK"
      IO.puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ callback"

      IO.inspect id, label: "ID"
      IO.inspect bounds, label: "BOUNDS"


      {left, top, right, bottom} = bounds # top is less than bottom, because the axis starts in top-left corner
      component_height = bottom - top
      between_tidbits_buffer = 25

      new_state = %{state|
                      active_components: state.active_components ++ [{id, bounds}],
                      acc_height: state.acc_height+component_height+between_tidbits_buffer
                    }

      IO.puts "HEIGHT: #{inspect bounds}"
      # ic scene
      # new_scene = scene
      # |> assign(open_tidbits: [{id, bounds}])

      # now, this scene will be able to use this data to render the
      # next TidBit in place!

      {:noreply, scene |> assign(state: new_state)}
  end
end
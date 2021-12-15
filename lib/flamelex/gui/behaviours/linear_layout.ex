defmodule Flamelex.GUI.Behaviours.LinearLayout do
    @moduledoc """
    Use this to turn your GUI.Component into a LinearLayout - a component
    which renders it's contents along an axis (could be both?) in such
    a way that the entries are lined up nicely (renders flexibly, depending on
    the width/height of the contents).

    Examples include:

    Menubars, e.g.
    "File"   "View"

    (this is perhaps the exception, where fixed-width offsets actually
    do make more sense).

    Tags, e.g.
    | ["some_tag"] | ["short"] | ["and_this_is_a_vary_long"] | ["tag"]

    And text blocks, e.g in StoryRiver for the Memex where we want to
    keep increasing the size of each TidBit, so the full thing gets shown,
    depending on the length of that particular tidbit's contents.
    """
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @margin_buffer 25              # When we render components, we put a margin between the outer frame and the inner components. This is the size of that margin (applied to all sides, horizontal & vertical)
    @min_position_cap {0, 0}       # used to cap (limit) the scrolling, so we don't just scroll for infinity if we have nothing left to render

  #   def validate(%{
  #       id: _id,
  #       frame: %Frame{} = _f,
  #       components: compnts,
  #       layout: {:vertical, :flex_grow}, #NOTE: Eventually, we want to have this available as "offset" aswell, for e.g. ManuBars - and plz blog this out one day!
  #       scroll: _s,
  #     } = data) and is_list(compnts) do

  #   Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
  #   {:ok, data}
  # end

  def validate(_data) do
      {:error, "#{__MODULE__} receiv'd invalid args."}
  end

  def init(scene, params, opts) do
    Logger.debug "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration - use params.id
    name = params.id #TODO we could use rego_tag here

    #NOTE: The `state` holds all the params which affect rendering
    state = %{
        id: params.id,
        active_components: [],                  # This is the list of components we have already rendered (and thus, got their bounds, and tracked their size). It starts out as the empty list.
        render_queue: [] = params.components,   # This is the list of components we haven't rendered yet. Components get rendered one at a time, so we can keep track of their bounds. We buffer rendering components until we have rendered all the other ones first.
        scroll: @min_position_cap               # Here we keep track of the current scroll position
      }  

    new_graph =
    Scenic.Graph.build()
    |> Scenic.Primitives.group(fn graph ->
         graph
       end, [
          #NOTE: We will scroll this pane around later on, and need to
          #      add new TidBits to it with Modify
          id: name,
          translate: state.scroll
       ])

    new_scene = scene
    |> assign(id: name)
    |> assign(state: state)
    |> assign(frame: params.frame)
    |> assign(graph: new_graph)
    |> push_graph(new_graph)

    # remember, they need to render "one at a time (yuck) - (or do they??) to get their positions"
    GenServer.cast(self(), :render_next_component) # trigger rendering of our (potential) backlog of components to render!

    request_input(new_scene, [:cursor_scroll])

    {:ok, new_scene}
  end


  def handle_call({:add_component, %{
        module: _compnt_mod,
        args: %{id: _id} = _compnt_args,
        opts: _compnt_opts
    } = c}, _from, scene) do

      state = scene.assigns.state
    new_state = %{state|render_queue: state.render_queue ++ [c]}

    new_scene = scene
    |> assign(state: new_state)

    GenServer.cast(self(), :render_next_component)

    {:reply, :ok, new_scene}
  end

  def handle_cast(:render_next_component, %{assigns: %{state: %{render_queue: []}}} = scene) do
    Logger.debug "#{__MODULE__} ignoring a request to render a component, there's nothing to render"
    {:noreply, scene}
  end

  def handle_cast(:render_next_component, scene = %{assigns: %{id: layout_id, state: %{
                     active_components: active_compnts,
                     render_queue: [%{
                         module: compnt_mod,
                         args: %{id: _id} = compnt_args,
                         opts: compnt_opts
                     } = _component_description|rest]}}}) do

    Logger.debug "Attempting to render next component in the LinearLayout..."

    frame = scene.assigns.frame
    state = scene.assigns.state
    new_state = %{state | render_queue: rest}

    acc_height = calc_acc_height(active_compnts)


    #NOTE - margin ought to be managed by the component itself - dont
    #       adjust the frame & pass it in, pass in margin as a prop

    #TODO get current scroll for the river_pane, so we can use it again
    #     as an option when we add the new HyperCard to the graph - I feel
    #     like Scenic should have respected my initial options, but anyway...

    #NOTE this is supposed to get the existing scroll but we need to cann it for now
    # [%{transforms: %{translate: scroll_coords}}] = Scenic.Graph.get(scene.assigns.graph, :river_pane)

    new_graph = scene.assigns.graph
    |> Scenic.Graph.add_to(layout_id, fn graph ->

          args = %{
            args: compnt_args,
            frame: Frame.new(
                        pin: {frame.top_left.x, frame.top_left.y+acc_height},
                        size: {frame.dimensions.width-(2*@margin_buffer), :flex})
          }
          # Kernel.apply(compnt_mod, :add_to_graph, [graph, args, [translate: scroll_coords]]) #TODO I dont think this actually worked
          #TODO need to merge args & opts, they should just be one - instead of calling add_to_graph, we should have our own component behaviour which wraps this nicer
          Kernel.apply(compnt_mod, :add_to_graph, [graph, args, compnt_opts]) #TODO this always resets us back moving the story river to default! Very annoying!!

    end)

    #NOTE this seems to have basically no effect on counter-acting the scroll reset when we open a new tidbit problem...
    # |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: scroll_coords))

    # then, riht at the end, call itself again until there's no render queue components (!?!?)
    #DONT try to keep rendering, the component calling back has to trigger that
    # GenServer.cast(self(), :render_next_component)

    new_scene = scene
    |> assign(state: new_state)
    |> assign(graph: new_graph)
    |> push_graph(new_graph)

    {:noreply, new_scene}
  end

    def handle_cast({:register_component_bounds, compnt, bounds}, %{assigns: %{state: state}} = scene) do
        # this callback is received when a component boots successfully -
        # it register itself to this component (parent-child relationship,
        # which ought to be able to handle props aswell!) including it's
        # own size (since I want Components to grow organizally based on their
        # size, and only wrap/clip in the most extreme circumstancses and/or
        # boundary conditions)
  
        new_state =
            %{state|active_components: state.active_components ++ [%{component: compnt, bounds: bounds}]}
  
        # Since one component just called back, we are ready to render
        # the next one if there are any which need it
        GenServer.cast(self(), :render_next_component)
  
        {:noreply, scene |> assign(state: new_state)}
    end

    def calc_acc_height(%{assigns: %{state: %{active_components: components}}}) do
        do_calc_acc_height(0, components)
    end

    defp do_calc_acc_height(acc, []), do: acc

    defp do_calc_acc_height(acc, [%{bounds: bounds} = c|rest]) do
        {_left, top, _right, bottom} = bounds # top is less than bottom, because the axis starts in top-left corner
        component_height = bottom - top
        new_acc = acc+component_height+@spacing_buffer
        do_calc_acc_height(new_acc, rest)
    end
    
end
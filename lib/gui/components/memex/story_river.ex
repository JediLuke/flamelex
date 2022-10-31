# defmodule Flamelex.GUI.Component.Memex.StoryRiver do
#     use Scenic.Component
#     use Flamelex.ProjectAliases
#     require Logger
#     # use ScenicWidgets.Macros.ImplementScrolling

#     @spacing_buffer 20 # the space between TidBits

#     #TODO when we need to render a list, need to stash them inside temp state memory until we get "next render" msg from last HyperCard
#     # just stash them all in memory & call :render_next_component once, that should do it
   

#     def validate(%{frame: %Frame{} = _f, state: %{
#         open_tidbits: _open_tidbits_list,
#         scroll: %{
#           accumulator: {_x, _y},
#           direction: :vertical,
#           components: [],
#           #acc_length: nil # this will get populated by the component, and will accumulate as TidBits get put in the StoryRiver 
#     }}} = data) do
#         Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
#         {:ok, data}
#     end


#     def init(scene, args, opts) do
#         Logger.debug "#{__MODULE__} initializing..."

#         Process.register(self(), __MODULE__)
#         Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

#         init_graph = render_new_story_river(args.state.scroll.accumulator)
#         init_state = args.state |> put_in([:open_tidbits], []) # start with no tidbits open, instead we load them into the render queue

#         init_scene = scene
#         |> assign(graph: init_graph)
#         |> assign(frame: args.frame)
#         |> assign(state: init_state)
#         |> assign(render_queue: args.state.open_tidbits) # used to buffer the rendering of flexible components (because they're flexible, so we can't render the next one until we know how big this one renders as)
#         |> push_graph(init_graph)

#         GenServer.cast(self(), :render_next_component) # kick-start the rendering here, it will take first item in the queue & render it

#         request_input(init_scene, [:cursor_scroll])

#         {:ok, init_scene}
#     end


#     def handle_cast(:render_next_component, %{assigns: %{render_queue: []}} = scene) do
#         Logger.debug "#{__MODULE__} ignoring a request to render a component, there's nothing to render"
#         {:noreply, scene}
#     end

#     def handle_cast(:render_next_component, %{assigns: %{render_queue: [tidbit|rest]}} = scene) do
#         Logger.debug "#{__MODULE__} attempting to render an additional component..."

#         #NOTE - pick up here tomorrow,
#         # -  basically add the new Hypercard to the graph
#         # - push a new graph
#         # - remember to take this component out of the render render_queu
#         # - next hypercard will kick off next render


#         # margin_buf = 2*@spacing_buffer # this is how much margin we render around each HyperCard

#         # frame = scene.assigns.frame
#         # state = scene.assigns.state
#         # new_state = %{state | render_queue: rest}

#         # acc_height = calc_acc_height(scene) #TODO loop through active components, calc height, including all spaced offsets!

#         # #NOTE - margin ought to be managed by the component itself - dont
#         # #       adjust the frame & pass it in, pass in margin as a prop

#         # #TODO get current scroll for the river_pane, so we can use it again
#         # #     as an option when we add the new HyperCard to the graph - I feel
#         # #     like Scenic should have respected my initial options, but anyway...

#         new_graph = scene.assigns.graph
#         |> Scenic.Graph.add_to(__MODULE__, fn graph ->
#             graph
#             |> Flamelex.GUI.Component.Memex.HyperCard.add_to_graph(%{
#                     id: tidbit.uuid,
#                     frame: calc_hypercard_frame(scene),
#                     state: tidbit
#                 })
#             end)
                
#         # #NOTE this is supposed to get the existing scroll but we need to cann it for now
#         # # [%{transforms: %{translate: scroll_coords}}] = Scenic.Graph.get(scene.assigns.graph, :river_pane)

#         # #NOTE this seems to have basically no effect on counter-acting the scroll reset when we open a new tidbit problem...
#         # # |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: scroll_coords))

#         new_state = scene.assigns.state
#         |> put_in([:open_tidbits], scene.assigns.state.open_tidbits ++ [tidbit])

#         new_scene = scene
#         |> assign(graph: new_graph)
#         |> assign(state: new_state)
#         |> assign(render_queue: rest)
#         |> push_graph(new_graph)

#         {:noreply, new_scene}
#     end

#     def handle_cast(
#         {:new_component_bounds, {id, bounds} = new_component_bounds},
#         %{assigns: %{state: state}} = scene
#     ) do
#         # this callback is received when a component boots successfully -
#         # it register itself to this component (parent-child relationship,
#         # which ought to be able to handle props aswell!) including it's
#         # own size (since I want TidBits to grow organizally based on their
#         # size, and only wrap/clip in the most extreme circumstancses and/or
#         # boundary conditions)

#         # NOTE: This callback `:new_component_bounds` is only useful
#         #      for keeping track of all the scrollable components. If
#         #      you need something else to happen when a sub-component
#         #      finished rendering (like say, rendering the next item,
#         #      in a list layout if these items were dynamically large)
#         #      then you will need to make your Components send _additional_
#         #      messages to the parent component, triggering whatever
#         #      other event it is you want to trigger on completion of
#         #      the sub-component rendering. This callback does not assume
#         #      responsibility for forwarding messages or any other messiness.

#         new_state = state
#         |> put_in([:scroll, :components], state.scroll.components ++ [new_component_bounds])

#         new_scene = scene
#         |> assign(state: new_state)

#         {:noreply, new_scene}
#     end

#     def handle_info({:radix_state_change, %{memex: %{story_river: new_story_river_state}}}, %{assigns: %{state: current_state}} = scene)
#         when new_story_river_state != current_state do
#             Logger.debug "#{__MODULE__} updating StoryRiver..."

#             new_graph = render_new_story_river(scene.assigns.state.scroll.accumulator)
#             new_state = new_story_river_state |> put_in([:open_tidbits], []) # start with no tidbits open, instead we load them into the render queue

#             new_scene = scene
#             |> assign(graph: new_graph)
#             |> assign(render_queue: new_story_river_state.open_tidbits)
#             |> assign(state: new_state)
#             |> push_graph(new_graph)

#             GenServer.cast(self(), :render_next_component) # kick-start the rendering here, it will take first item in the queue & render it
    
#             {:noreply, new_scene}
#     end

#     #NOTE: If `story_river_state` binds on both variables here, then they are the same, no state-change occured and we can ignore this update
#     def handle_info({:radix_state_change, %{memex: %{story_river: story_river_state}}}, %{assigns: %{state: story_river_state}} = scene) do
#         {:noreply, scene}
#     end

#     def handle_input(
#         {:cursor_scroll, {{_x_scroll, _y_scroll} = delta_scroll, coords}},
#         _context,
#         scene
#       ) do
#         Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:scroll, delta_scroll, __MODULE__}})
#         {:noreply, scene}
#     end

#     def render_new_story_river(scroll_pos) do
#         # This way the graph has a Group with the right name already, so
#         # we can just use Scenic.Graph.add to add new HyperCards
#         Scenic.Graph.build()
#         |> Scenic.Primitives.group(fn graph ->
#             graph
#         end, [
#             id: __MODULE__,
#             translate: scroll_pos
#         ])
#     end

#     def calc_hypercard_frame(%{assigns: %{
#         frame: %Frame{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}},
#         state: %{
#             scroll: %{components: component_list}
#     }}}) do
#         #TODO really calculate height
#         open_tidbits_offset = 500*Enum.count(component_list)
#         extra_vertial_space = @spacing_buffer*Enum.count(component_list)
#         Frame.new(
#             top_left: {x+@spacing_buffer, y+@spacing_buffer+open_tidbits_offset+extra_vertial_space},
#             dimensions: {w-(2*@spacing_buffer), {:flex_grow, %{min_height: 500}}})
#     end

#     # <3 @vacarsu
#     # def cap_position(%{assigns: %{frame: frame}} = scene, coord) do
#     #     # NOTE: We must keep track of components, because one could
#     #     #      get yanked out the middle.
#     #     height = calc_acc_height(scene)
#     #     # height = scene.assigns.state.scroll.acc_length
#     #     if height > frame.dimensions.height do
#     #         coord
#     #         |> calc_floor({0, -height + frame.dimensions.height / 2})
#     #         |> calc_ceil({0, 0})
#     #     else
#     #         coord
#     #         |> calc_floor(@min_position_cap)
#     #         |> calc_ceil(@min_position_cap)
#     #     end
#     # end

#     def calc_acc_height(components) when is_list(components) do
#         do_calc_acc_height(0, components)
#     end

#     # def calc_acc_height(%{assigns: %{state: %{scroll: %{components: components}}}}) do
#     #     do_calc_acc_height(0, components)
#     # end

#     def do_calc_acc_height(acc, []), do: acc



#     def do_calc_acc_height(acc, [{_id, bounds} = c | rest]) do
#         # top is less than bottom, because the axis starts in top-left corner
#         {_left, top, _right, bottom} = bounds
#         component_height = bottom - top

#         new_acc = acc + component_height + @spacing_buffer
#         do_calc_acc_height(new_acc, rest)
#     end

#     # defp calc_floor({x, y}, {min_x, min_y}), do: {max(x, min_x), max(y, min_y)}

#     # defp calc_ceil({x, y}, {max_x, max_y}), do: {min(x, max_x), min(y, max_y)}
        

#     # def hypercard_frame(%Frame{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#     #     bm = _buffer_margin = 50 # px
#     #     Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), {:flex_grow, %{min_height: 500}}})
#     # end

#     # def second_hypercard_frame(%Frame{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
#     #     bm = _buffer_margin = 50 # px
#     #     Frame.new(top_left: {x+bm+20, y+bm+600}, dimensions: {w-(2*bm), {:flex_grow, %{min_height: 500}}})
#     # end

#     # def render_tidbits(graph, %{state: %{open_tidbits: []}} = _story_river_state) do
#     #     graph |> Scenic.Graph.delete(__MODULE__)
#     # end

#     # def render_tidbits(graph, %{state: %{open_tidbits: [%Memelex.TidBit{} = tidbit], scroll: scroll}, frame: frame}) do
#     #     new_graph = graph
#     #     |> Scenic.Graph.delete(__MODULE__)
#     #     |> Scenic.Primitives.group(fn graph ->
#     #             graph
#     #             |> Flamelex.GUI.Component.Memex.HyperCard.add_to_graph(%{
#     #                     id: tidbit.uuid,
#     #                     frame: hypercard_frame(frame),
#     #                     state: tidbit
#     #             })
#     #         end, [
#     #             id: __MODULE__,
#     #             translate: scroll.accumulator
#     #         ])
#     # end


# end
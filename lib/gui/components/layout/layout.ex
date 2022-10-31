# defmodule Flamelex.GUI.Component.Layout do
#     @defmodule """
#     A high-order component which wraps around a list of other components,
#     allows them to be dynamically sized, and re-arranges it's child-components
#     based on some pre-defined rules.

#     One example is how we use the Layout to handle the placement of
#     tags inside HyperCard.TagsBox
#     """
#     use Scenic.Component
#     require Logger
#     alias ScenicWidgets.Core.Structs.Frame
    
#     #NOTE: components is a list of functions
#     # todo - dunno why but we cant pattern match on a %Frame{} here
#     # def validate(%{frame: %Frame{} = _f, components: _c, layout: _l} = data), do: data
#     # def validate(%{frame: _f, components: _c, layout: _l} = data) do
#     def validate(data) do
#         {:ok, data}
#     end

#     def init(scene, args, opts) do

#         # #TODO here, we need to wrap each component inside yet another
#         # component, which is the one which does all the callbacks - maybe
#         # we can use a macro to simply inject this code in here

#         init_scene = scene
#         |> assign(frame: args.frame)
#         |> assign(render_queue: args.components) # used to buffer the rendering of flexible components (because they're flexible, so we can't render the next one until we know how big this one renders as)
#         #TODO put something in here saying, we're waiting a bounds callback for component, then we will know if it's time to render the next component (when we get that callback)
#         |> assign(layout: []) # no components in the layout yet
#         # |> assign(id: args.id)
#         # |> assign(graph: args.graph)
#         # |> push_graph(args.graph)

#         # Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

#         GenServer.cast(self(), :render_next) # kick-start the rendering here, it will take first item in the queue & render it

#         {:ok, init_scene}
#     end

#     def handle_cast(:render_next, %{assigns: %{render_queue: []}} = scene) do
#         Logger.debug "#{__MODULE__} ignoring a request to render a component, there's nothing to render"
#         {:noreply, scene}
#     end

#     #NOTE: This is rendering the first component
#     def handle_cast(:render_next, %{assigns: %{render_queue: [component|rest], layout: []}} = scene) do
#         Logger.debug "#{__MODULE__} attempting to render an additional component..."


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
#         tag_frame = Frame.new(
#             # top_left: {x+@spacing_buffer, y+@spacing_buffer+open_tidbits_offset+extra_vertial_space},
#             top_left: {0, 0},
#             dimensions: {{:flex_grow, %{min_width: 80}}, 25}) #TODO figure out the height based on the font height

#         graph = Scenic.Graph.build()
#         new_graph = component.(graph, %{frame: tag_frame})

#         # new_graph = scene.assigns.graph
#         # |> Scenic.Graph.add_to(__MODULE__, fn graph ->
#         #     graph
#         #     |> Flamelex.GUI.Component.Memex.HyperCard.add_to_graph(%{
#         #             id: tidbit.uuid,
#         #             frame: calc_hypercard_frame(scene),
#         #             state: tidbit
#         #         })
#         #     end)
                
#         # #NOTE this is supposed to get the existing scroll but we need to cann it for now
#         # # [%{transforms: %{translate: scroll_coords}}] = Scenic.Graph.get(scene.assigns.graph, :river_pane)

#         # #NOTE this seems to have basically no effect on counter-acting the scroll reset when we open a new tidbit problem...
#         # # |> Scenic.Graph.modify(:river_pane, &Scenic.Primitives.update_opts(&1, translate: scroll_coords))

#         # new_state = scene.assigns.state
#         # |> put_in([:open_tidbits], scene.assigns.state.open_tidbits ++ [tidbit])

#         new_scene = scene
#         |> assign(graph: new_graph)
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

#         # new_state = state
#         # |> put_in([:scroll, :components], state.scroll.components ++ [new_component_bounds])

#         # new_scene = scene
#         # |> assign(state: new_state)

#         {:noreply, scene}
#     end







# #   # def handle_info({:radix_state_change,
# #   #       %{root: %{layers: %{two: new_second_layer}}}},
# #   #       %{assigns: %{layer_2: current_layer_2}} = scene)
# #   # when new_second_layer != current_layer_2 do
# #   def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do

# #     this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
# #     [{^this_layer, radix_layer_graph}] =
# #         layer_list |> Enum.filter(fn {layer, graph} -> layer == scene.assigns.id end)

# #     if scene.assigns.graph != radix_layer_graph do
# #         Logger.debug "#{__MODULE__} Layer_#{inspect scene.assigns.id} changed, re-drawing the RootScene..."
        
# #         new_scene = scene
# #         |> assign(graph: radix_layer_graph)
# #         |> push_graph(radix_layer_graph)

# #         {:noreply, new_scene}
# #     else
# #         Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
# #         {:noreply, scene}
# #     end
# #   end

# #   def handle_info({:radix_state_change, _new_radix_state}, scene) do
# #     Logger.debug "#{__MODULE__} ignoring a RadixState change..."
# #     {:noreply, scene}
# #   end

# end
# defmodule Flamelex.GUI.Component.Layoutable do
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
#     def validate(%{id: _id} = data) do
#         {:ok, data}
#     end

#     def init(scene, args, opts) do

#         #TODO render the graph, put a clear rectangle the size of the frame on the bottom to ensure it has full bounds

#         init_scene = scene
#         |> assign(id: args.id)
#         # |> assign(frame: args.frame)
#         # |> assign(graph: args.graph)
#         # |> push_graph(args.graph)

#         {:ok, init_scene, {:continue, :publish_bounds}}
#     end

#     def handle_continue(:publish_bounds, scene) do
#         bounds = Scenic.Graph.bounds(scene.assigns.graph)

# 		send_parent_event(scene, {:update_bounds, %{id: "j", bounds: bounds}})
# 		|> GenServer.cast({:new_component_bounds, {scene.assigns.state.uuid, bounds}})
        
#         {:noreply, scene, {:continue, :render_next_hyper_card}}
#     end
# end
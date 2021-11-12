# defmodule Flamelex.GUI.Utils.ComponentUtils do

#     @skip_log true

#     def render_push_graph(%{assigns: %{state: init_state}} = scene) do
#         #NOTE: On the flip side, we are (potentially? Maybe Scenic optimizes?)
#         #      re-drawing the entire graph for every mouse-movement...
#         case Wormhole.capture(Utils, :render, [scene], skip_log: @skip_log) do
#           {:ok, new_scene} ->
#             new_scene |> push_graph(new_scene.assigns.graph)
#           {:error, reason} ->
#             Logger.error "#{__MODULE__} unable to render Scene! #{inspect reason}"
#             scene # make no changes
#         end
#     end
# end
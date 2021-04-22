# defmodule Flamelex.GUI.GraphConstructors.Frame do
#   @moduledoc """
#   This module takes in an input data source (usually a struct) and returns
#   a %Scenic.Graph{} which corresponds to it.

#   Each of these is a pure function, it's a totally declarative state ->
#   graph mapping.
#   """
#   use Flamelex.ProjectAliases

#   def convert(%Frame{} = frame) do
#     bar_height = 24 #TODO why is this hard-coded??
#     Scenic.Graph.build()
#     # draw header & footer before frame to get a nice "window" appearance
#     |> draw_header_bar(frame, bar_height)
#     |> draw_footer_bar(frame, bar_height)
#     |> Draw.border_box(frame)
#     |> Draw.render_inner_buffer(frame, bar_height)
#   end

#   def convert_2(%Frame{} = frame) do
#     bar_height = 24 #TODO why is this hard-coded??
#     Scenic.Graph.build()
#     # draw header & footer before frame to get a nice "window" appearance
#     |> draw_header_bar(frame, bar_height, :cyan)
#     |> draw_footer_bar(frame, bar_height)
#     |> Draw.border_box(frame)
#     |> Draw.render_inner_buffer(frame, bar_height)
#   end


#   defp draw_header_bar(graph, frame, height, fill \\ :green) do
#     graph
#     |> Scenic.Primitives.rect(
#          {frame.dimensions.width, height}, [
#             fill: fill,
#             translate: {
#               frame.top_left.x,
#               frame.top_left.y}])
#     |> Scenic.Primitives.text(frame.buffer.name,
#             fill: :black,
#             translate: {
#               frame.top_left.x + 50, #TODO need to take text width into account here but good enough for now - would look nice centered
#               frame.top_left.y + 20}) #TODO god damnit Scenic why do you draw text from bottom-left??
#   end

#   defp draw_footer_bar(graph, frame, height) do
#     graph
#     |> Scenic.Primitives.rect(
#          {frame.dimensions.width, height}, [
#             fill: :grey,
#             translate: {
#               frame.top_left.x,
#               frame.top_left.y + frame.dimensions.height - height}])
#   end
# end

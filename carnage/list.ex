


  # def new_list_buffer do
  #   raise "lol?"
  #   #   alias GUI.Scene.Root, as: Franklin
  #   #   def new_buffer(:test) do
  #   #     new_buffer(%{
  #   #       type: :list,
  #   #       data: [
  #   #         {"iderieri", %{
  #   #           title: "Luke",
  #   #           text: "First note"
  #   #         }},
  #   #         {"ikey-heihderieri", %{
  #   #           title: "Leah",
  #   #           text: "Second note"
  #   #         }}
  #   #       ]
  #   #     })
  #   #   end




# defmodule GUI.Component.List do
#   @moduledoc false
#   use Scenic.Component
#   require Logger
#   # import Components.Utilities.CommonDrawingFunctions
#   alias GUI.Structs.Frame

#   @ibm_plex_mono Flamelex.GUI.Initialize.ibm_plex_mono_hash

#   def verify(%{
#     id: _id,
#     top_left_corner: {_x, _y},
#     dimensions: {_w, _h},
#     contents: _contents
#   } = data), do: {:ok, data}
#   def verify(_), do: :invalid_data

#   def info(_data), do: ~s(Invalid data)

#   # def handle_call(:deactivate, {_pid, _ref}, {state, graph}) do
#   #   Logger.info "#{__MODULE__} deactivating..."
#   #   {:reply, :ok, {state, graph}}
#   # end

#   @doc false
#   def init(%{
#     id: id,
#     top_left_corner: {_x, _y},
#     dimensions: {w, h},
#     contents: contents
#   } = data, _opts) do
#     Logger.info "#{__MODULE__} initializing...#{inspect data}"

#     IO.inspect contents, label: "CCC"

#     graph =
#       Scenic.Graph.build()
#       # |> add_buffer_frame(%BufferFrame{
#       #      buffer_type: :list,
#       #      name: "List buffer",
#       #      width: w,
#       #      height: h
#       # })

#     {graph, _offset_count} =
#       # Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note} = iter, {graph, offset_count} ->
#       #TODO have a note data structure
#       Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note} = iter, {graph, offset_count} ->

#         IO.inspect iter, label: "HIHIHI"

#         graph =
#           graph
#           |> Scenic.Primitives.group(fn graph ->
#                graph
#                |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
#                |> Scenic.Primitives.text(note.title, font: @ibm_plex_mono,
#                     translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#                     font_size: 24, fill: :black)
#              end)

#         {graph, offset_count + 1}
#       end)

#     state = %{}

#     # GenServer.call(GUI.Scene.Root, {:register, id}) #TODO make this work!!
#     {:ok, {state, graph}, push: graph}
#   end

#   # defp add_notes(graph, contents) do
#   #   {graph, _offset_count} =
#   #     Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
#   #       graph =
#   #         graph
#   #         |> Scenic.Primitives.group(fn graph ->
#   #               graph
#   #               |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
#   #               |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
#   #                   translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#   #                   font_size: 24, fill: :black)
#   #             end)


#   #       {graph, offset_count + 1}
#   #     end)

#   #   graph
#   # end
# end

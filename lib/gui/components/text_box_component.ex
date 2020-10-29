defmodule Flamelex.GUI.Component.TextBox do
  @moduledoc false
  use Scenic.Component
  require Logger
  use Flamelex.ProjectAliases

  @ibm_plex_mono GUI.FontHelpers.font(:ibm_plex_mono)

  #TODO have horizontal scrolling if we go over the line
  def draw(graph, {frame, data}) do
    add_to_graph(graph, {frame, data})
  end

  @impl Scenic.Component
  def verify({%Frame{} = _f, _data} = params), do: {:ok, params}
  def verify(_else), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  # def handle_call(:deactivate, {_pid, _ref}, {state, graph}) do
  #   Logger.info "#{__MODULE__} deactivating..."
  #   {:reply, :ok, {state, graph}}
  # end

  @doc false
  def init({%Frame{} = f, data} = state, _opts) do
    Logger.info "#{__MODULE__} initializing..."

    # GenServer.call(GUI.Scene.Root, {:register, id})
    # state =
    #   data
    left_margin = 8

    background_color = GUI.Colors.background()
    text_color = GUI.Colors.foreground()

    graph =
      Scenic.Graph.build()
      |> Draw.background(f, background_color)
      |> Scenic.Primitives.text(data,
                 font: @ibm_plex_mono,
                 translate: {f.coordinates.x + left_margin, f.coordinates.y + 22}, # text draws from bottom-left corner?? :( also, how high is it???
                 font_size: 24,
                 fill: text_color)

      # |> GUI.Component.Cursor.add_to_graph(data |> cursor_params())


    {:ok, {state, graph}, push: graph}
  end


  #         #TODO right now the text runs outside of the frame! We need to use dimensions here somehow to limit the size of the draw
  #         graph
  #         |> Scenic.Primitives.text(
  #              buf.content,
  #                font: @ibm_plex_mono,
  #                translate: {frame_x + 5, frame_y + bar_height + 22}, # text draws from bottom-left corner?? :( also, how high is it???
  #                font_size: 24,
  #                fill: :ghost_white)





#   def add_buffer_frame(%Graph{} = graph, %BufferFrame{} = data) do
#     #TODO do we need +1 for width here??
#     frame_height = Application.fetch_env!(:franklin, :bar_height)
#     graph
#     # |> rect({w, h-frame_height}, stroke: {3, :cornflower_blue})
#     |> rect({data.width + 1, frame_height}, translate: {0, data.height-frame_height}, fill: :light_blue)
#     |> text(data.name, translate: {0+2, data.height-4}, fill: :black)
#   end
# end




    # def render_inner_buffer(
  #       %Scenic.Graph{} = graph,
  #       %Frame{
  #         dimensions:  %Dimensions{width: frame_width, height: frame_height},
  #         coordinates: %Coordinates{x: frame_x, y: frame_y},
  #         buffer:      %Buffer{type: :text} = buf
  #       },
  #       bar_height
  #     ) do

  #         #TODO right now the text runs outside of the frame! We need to use dimensions here somehow to limit the size of the draw
  #         graph
  #         |> Scenic.Primitives.text(
  #              buf.content,
  #                font: @ibm_plex_mono,
  #                translate: {frame_x + 5, frame_y + bar_height + 22}, # text draws from bottom-left corner?? :( also, how high is it???
  #                font_size: 24,
  #                fill: :ghost_white)
  # end


















  # def init(%{id: id, top_left_corner: {_x, _y}, dimensions: {w, h}} = data, _opts) do
  # end

  # defp add_notes(graph, contents) do
  #   {graph, _offset_count} =
  #     Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
  #       graph =
  #         graph
  #         |> Scenic.Primitives.group(fn graph ->
  #               graph
  #               |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
  #               |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
  #                   translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
  #                   font_size: 24, fill: :black)
  #             end)


  #       {graph, offset_count + 1}
  #     end)

  #   graph
  # end

  defp cursor_params(%{
    dimensions: {_width, height},
    id: :text_box,
    top_left_corner: {x, y}
  }) do
    cursor_width = GUI.FontHelpers.monospace_font_width(:ibm_plex, 24) #TODO get this properly
    %{
      id: :cursor,
      top_left_corner: {x, y},
      dimensions: {cursor_width, height}
    }
  end
end

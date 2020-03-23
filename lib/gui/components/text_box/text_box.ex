defmodule Components.TextBox do
  @moduledoc false
  use Scenic.Component
  require Logger
  import Components.Utilities.CommonDrawingFunctions
  alias GUI.Component.Cursor

  #TODO have horizontal scrolling if we go over the line

  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h}
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  # def handle_call(:deactivate, {_pid, _ref}, {state, graph}) do
  #   Logger.info "#{__MODULE__} deactivating..."
  #   {:reply, :ok, {state, graph}}
  # end

  @doc false
  def init(%{id: _id, top_left_corner: {_x, _y}, dimensions: {w, h}} = data, _opts) do
    Logger.info "#{__MODULE__} initializing...#{inspect data}"

    # GenServer.call(GUI.Scene.Root, {:register, id})
    state =
      data

    graph =
      Scenic.Graph.build()
      |> background(state, :red)
      |> GUI.Component.Cursor2.add_to_graph(data |> cursor_params())


    IO.puts "HIHIHIHI"
    {:ok, {state, graph}, push: graph}
  end
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

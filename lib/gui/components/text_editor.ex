defmodule GUI.Component.TextEditor do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives
  require Logger
  import Utilities.ComponentUtils

  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash

  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h},
    contents: _contents
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  # def handle_call(:deactivate, {_pid, _ref}, {state, graph}) do
  #   Logger.info "#{__MODULE__} deactivating..."
  #   {:reply, :ok, {state, graph}}
  # end

  @doc false
  def init(%{
    id: id,
    top_left_corner: {_x, _y},
    dimensions: {w, h},
    contents: contents
  } = data, _opts) do
    Logger.info "#{__MODULE__} initializing...#{inspect data}"

    state = %{
      text: contents
    }

    graph =
      Scenic.Graph.build()
      |> GUI.Component.BufferFrame.add_buffer_frame({w, h}, :control)
      |> text(state.text,
           translate: {18, 18},
           fill: :white)

    GenServer.call(GUI.Scene.Root, {:register, id})
    {:ok, {state, graph}, push: graph}
  end

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
end

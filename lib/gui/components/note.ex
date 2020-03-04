defmodule GUI.Component.Note do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives

  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h}
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  @doc false
  def init(%{
    id: id,
    top_left_corner: {x, y},
    dimensions: {width, height}
  }, _opts) do
    graph =
      Graph.build()
      |> rect({width, height}, translate: {x, y}, fill: :dark_slate_blue, stroke: {1, :ghost_white})

    GenServer.call(GUI.Scene.Root, {:register, id})
    {:ok, %{}, push: graph}
  end
end

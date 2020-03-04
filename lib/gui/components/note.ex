defmodule GUI.Component.Note do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives

  def verify(%{} = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  @doc false
  def init(_data, _opts) do
    graph =
      Graph.build()
      |> rect({200, 200}, translate: {100, 100}, fill: :green, stroke: {1, :ghost_white})

    GenServer.call(GUI.Scene.Root, {:register, :untitled_note})
    {:ok, %{}, push: graph}
  end
end

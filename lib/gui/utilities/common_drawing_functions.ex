defmodule Components.Utilities.CommonDrawingFunctions do
  import Scenic.Primitives
  alias Scenic.Graph

  def background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}, color) when is_atom(color) do
    #TODO need width +1 here for some quirky reason of Scenic library
    graph
    |> rect({w + 1, h}, [fill: color, translate: {x, y}])
  end
  def background(graph, %{top_left_corner: {x, y}, dimensions: {w, h}}) do
    #TODO need width +1 here for some quirky reason of Scenic library
    graph
    |> rect({w + 1, h}, [translate: {x, y}]) #TODO only green for dev
  end
end

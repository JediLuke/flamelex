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


  def add_buffer_frame(%Graph{} = graph, {w, h}) do
    #TODO do we need +1 for width here??
    frame_height = Application.fetch_env!(:franklin, :bar_height)
    graph
    # |> rect({w, h-frame_height}, stroke: {3, :cornflower_blue})
    |> rect({w + 1, frame_height}, translate: {0, h-frame_height}, fill: :light_blue)
  end
end

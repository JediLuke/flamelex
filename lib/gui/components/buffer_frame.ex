defmodule GUI.Component.BufferFrame do

  def add_buffer_frame(%Scenic.Graph{} = graph, {w, h}) do
    graph
    |> Scenic.Primitives.rect({w, h}, stroke: {3, :yellow})
    |> Scenic.Primitives.rect({w, 20}, translate: {0, h-20}, fill: :yellow)
  end
end

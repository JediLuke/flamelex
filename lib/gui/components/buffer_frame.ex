defmodule GUI.Component.BufferFrame do

  @default_status_bar_height 24

  def add_buffer_frame(%Scenic.Graph{} = graph, {w, h}, :control) do
    graph
    # |> Scenic.Primitives.rect({w, h}, stroke: {3, :cornflower_blue})
    |> Scenic.Primitives.rect({w+1, @default_status_bar_height}, translate: {0, h-@default_status_bar_height}, fill: :light_blue)
  end
end

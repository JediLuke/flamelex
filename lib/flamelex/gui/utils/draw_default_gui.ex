defmodule Flamelex.GUI.Utils.DefaultGUI.NEW do
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.GUI.Utilities.Draw

  # alias LayoutOMatic.Layouts.Components.Layout, as: AutoLayout


  #TODO ok so here - what we need is a cohesive, layered, auto-layout system

  def draw(_state) do
    Scenic.Graph.build()
    |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    |> Scenic.Primitives.rect({80, 80}, fill: :green,  translate: {140, 140})
  end
  # def draw(%{viewport: vp, layers: layers} = state) do

  #   base_graph = Scenic.Graph.build()

  #   new_graph = Enum.reduce(layers, base_graph, fn layr, scene ->
  #         scene |> draw_layer(layr)
  #       end)

  #   # {%{state|graph: new_graph}, new_graph}
  #   new_graph
  # end

  # def draw(state) do
  #   draw(state |> Map.merge(%{layers: [
  #       %{num: 1, id: :renseijin, draw_function: renseijin()},
  #       # %{num: 2, id: :test,      draw_function: test_draw()},
  #       # %{num: 3, id: :test,      draw_function: test_draw(:yellow)}
  #     ]}))
  # end


  # def draw_layer(graph, %{id: id, num: x, draw_function: draw_fn}) when x >= 1 do

  #   #TODO this is really it - now we need auto-layouts
  #   #TODO each layer, needs an AutoLayout, a level (they render on top of eachother, and we can re-order them?) & the ability to hide
  #   # needs vidibility toggle
  #   # needs viewport/max size

  #   #TODO add a test overlay which shows the layer number

  #   graph |> Scenic.Primitives.group(draw_fn, id: {:layer, id, x})
  # end




  # def renseijin() do
  #   # returns a function, which takes a graph, which will be passed to the Scenic group
  #   IO.puts "AND NOW WE RETURN A FUNC"
  #   fn(graph) ->
  #     g = graph |> Draw.test_pattern()
  #     # {:ok, new_graph} =  graph # AutoLayout.auto_layout(g, :left_group_grid, [{:layer, :renseijin, 1}])
  #     # new_graph
  #   end
  # end
end

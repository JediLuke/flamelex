defmodule GUI.Utilities.Draw do
  import Scenic.Primitives
  alias Scenic.Graph
  # alias Components.TextBox

  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash()

  def blank_graph do
    Graph.build()
  end

  def rectangle(%Scenic.Graph{} = graph) do
    graph
    |> rect({50, 50}, [fill: :red, translate: {200, 200}])
  end

  def text(%Scenic.Graph{} = graph, t) do
    blank_graph()
    |> text(t, font: @ibm_plex_mono,
               translate: {5, 24}, # text draws from bottom-left corner?? :( also, how high is it???
               font_size: 24, fill: :white)
  end
end

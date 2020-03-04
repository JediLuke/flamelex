defmodule GUI.Component.Note do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives

  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash

  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h},
    contents: %{
      title: _title,
      text: _text
    }
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  @doc false
  def init(%{
    id: id,
    top_left_corner: {x, y},
    dimensions: {width, height},
    contents: %{title: title, text: note_contents}
  }, _opts) do
    font_size = 48
    graph =
      Graph.build()
      |> rect({width, height}, translate: {x, y}, fill: :cornflower_blue, stroke: {1, :ghost_white})
      |> text(title,
         id: :title,
         font: @ibm_plex_mono,
         translate: {x+15, y+font_size}, # text draws from bottom-left corner?? :( also, how high is it???
         font_size: font_size,
         fill: :black)
      |> line({{x+15, y+font_size+25}, {x+width-15, y+font_size+25}}, stroke: {3, :black})
      |> text(note_contents,
         id: :title,
         font: @ibm_plex_mono,
         translate: {x+15, y+font_size+65}, # text draws from bottom-left corner?? :( also, how high is it???
         fill: :black)

    GenServer.call(GUI.Scene.Root, {:register, id})
    {:ok, %{}, push: graph}
  end
end

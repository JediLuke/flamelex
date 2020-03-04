defmodule GUI.Component.Note do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives

  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash

  @title_prompt "New note..."
  @text_prompt "Press <TAB> to move to the text input area."

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
  } = data, _opts) do
    title_text = if title == "", do: @title_prompt, else: title
    note_text = if note_contents == "", do: @text_prompt, else: title
    title_font_size = 48

    #TODO remove/hide cursor if focus leaves this window (or we go into command mode)
    #TODO if note crashes, Root needs to monitor it & remove it from it's component refs - but it's being restarted???

    graph =
      Graph.build()
      |> rect({width, height}, translate: {x, y}, fill: :cornflower_blue, stroke: {1, :ghost_white})
      |> text(title_text,
         id: :title,
         font: @ibm_plex_mono,
         translate: {x+15, y+title_font_size}, # text draws from bottom-left corner?? :( also, how high is it???
         font_size: title_font_size,
         fill: :black)
      |> add_cursor(data, title_font_size)
      |> line({{x+15, y+title_font_size+25}, {x+width-15, y+title_font_size+25}}, stroke: {3, :black})
      |> text(note_text,
         id: :text,
         font: @ibm_plex_mono,
         translate: {x+15, y+title_font_size+65}, # text draws from bottom-left corner?? :( also, how high is it???
         fill: :black)

    GenServer.call(GUI.Scene.Root, {:register, id})
    {:ok, {_state = %{}, graph}, push: graph}
  end

  def handle_cast({'TITLE_INPUT', %{focus: :title, title: new_title}}, {state, graph}) do
    new_graph =
      graph |> Graph.modify(:title, &text(&1, new_title, fill: :black))

    {:noreply, {state, new_graph}, push: new_graph}
  end

  defp add_cursor(graph, %{top_left_corner: {x, y}}, font_size) do
    {_x_min, _y_min, _x_max, y_max} =
      GUI.FontHelpers.get_max_box_for_ibm_plex(font_size)

    y_offset     = y+10
    y_box_buffer = 2 # it looks weird having box exact same size as the text
    x_coordinate = x+15
    y_coordinate = y_offset + y_box_buffer
    width        = GUI.FontHelpers.monospace_font_width(:ibm_plex, font_size)  #TODO should probably truncate this
    height       = y_max + y_box_buffer #TODO should probably truncate this

    graph
    |> GUI.Component.BlinkingBox.add_to_graph(%{
          top_left_corner: {x_coordinate, y_coordinate},
          dimensions: {width, height}
        })
  end
end

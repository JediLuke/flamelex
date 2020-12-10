defmodule Flamelex.GUI.Component.DeprecatedTextBox do
  @moduledoc false
  use Scenic.Component
  require Logger
  use Flamelex.ProjectAliases



  # def handle_cast({:refresh, buf}, state) do
  #   state = %{state|text: buf.data}
  #   new_graph = render_graph(state)
  #   new_state = %{state| graph: new_graph}
  #   {:noreply, new_state, push: new_graph}
  # end

  def handle_cast({:move_cursor, direction, _dist}, state) do

    _old_cursr_position = %{row: rr, col: cc} = state.cursor_position
    new_cursor_position =
      case direction do
        :left  -> %{row: rr,   col: cc-1}
        :down  -> %{row: rr-1, col: cc}
        :up    -> %{row: rr+1, col: cc}
        :right -> %{row: rr,   col: cc+1}
      end

    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: new_cursor_position,
           cursor_blink?: state.cursor_blink?
         })
      |> Frame.draw(state.frame, %{mode: :normal})

    new_state = %{state| graph: new_graph,
                         cursor_position: new_cursor_position }

    {:noreply, new_state, push: new_graph}
  end

  def handle_cast({:move_cursor, new_cursor_position}, state) do

    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: new_cursor_position,
           cursor_blink?: state.cursor_blink?
         })
      |> Frame.draw(state.frame, %{mode: state.mode})

    new_state = %{state| graph: new_graph,
                         cursor_position: new_cursor_position }

    {:noreply, new_state, push: new_graph}
  end

  def handle_cast({:switch_mode, m}, state) do
    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: state.cursor_position,
           cursor_blink?: state.cursor_blink?,
           mode: m
         })
      |> Frame.draw(state.frame, %{mode: m})

    new_state = %{state| graph: new_graph, mode: m}

    {:noreply, new_state, push: new_graph}
  end

  def handle_info(:blink, state) do

    new_blink = not state.cursor_blink?

    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, Flamelex.GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: state.cursor_position,
           cursor_blink?: new_blink,
           mode: state.mode
         })
      |> Frame.draw(state.frame, %{mode: state.mode})

    new_state =
      %{state|graph: new_graph, cursor_blink?: new_blink}

    {:noreply, new_state, push: new_graph}
  end


  # defp add_notes(graph, contents) do
  #   {graph, _offset_count} =
  #     Enum.reduce(contents, {graph, _offset_count = 0}, fn {_key, note}, {graph, offset_count} ->
  #       graph =
  #         graph
  #         |> Scenic.Primitives.group(fn graph ->
  #               graph
  #               |> Scenic.Primitives.rect({w / 2, 100}, translate: {10, 10 + offset_count * 110}, fill: :cornflower_blue, stroke: {1, :ghost_white})
  #               |> Scenic.Primitives.text(note["title"], font: ibm_plex_mono,
  #                   translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
  #                   font_size: 24, fill: :black)
  #             end)


  #       {graph, offset_count + 1}
  #     end)

  #   graph
  # end

  # defp cursor_params(%{
  #   dimensions: {_width, height},
  #   id: :text_box,
  #   top_left_corner: {x, y}
  # }) do
  #   cursor_width = GUI.FontHelpers.monospace_font_width(:ibm_plex, 24) #TODO get this properly
  #   %{
  #     id: :cursor,
  #     top_left_corner: {x, y},
  #     dimensions: {cursor_width, height}
  #   }
  # end
end

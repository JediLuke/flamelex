defmodule Flamelex.GUI.Component.TextBox do
  @moduledoc false
  use Scenic.Component
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.GUI.Utilities.Drawing.TextComponentDrawingLib, as: TextBoxDraw

  @blink_ms trunc(500) # blink speed in hertz


  #TODO have horizontal scrolling if we go over the line

  def draw(graph, {frame, data}) do
    add_to_graph(graph, {frame, data})
  end

  def verify({%Frame{} = _f, _data} = params), do: {:ok, params}
  def verify(_else), do: :invalid_data

  def info(_data), do: ~s(Invalid data)


  @doc false
  def init({%Frame{} = frame, text} = state, _opts) do

    Logger.info "#{__MODULE__} initializing..."

    ProcessRegistry.gproc_register({:gui_component, frame.id})

    cursor_position = %{row: 0, col: 0}

    GenServer.cast(self(), :start_blink)

    graph =
      Draw.blank_graph()
      |> Draw.background(frame, GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: frame,
           text: text,
           cursor_position: cursor_position,
           cursor_blink?: false
         })

    new_state = %{
      graph: graph,
      frame: frame,
      text: text,
      cursor_position: cursor_position,
      cursor_blink?: false,
      timer: nil
    }

    {:ok, new_state, push: graph}
  end

  def handle_cast(:start_blink, state) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, new_state}
  end

  def handle_cast(:move_cursor_right, state) do

    _old_cursr_position = %{row: rr, col: cc} = state.cursor_position
    new_cursor_position = %{row: rr, col: cc+1}

    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: new_cursor_position,
           cursor_blink?: state.cursor_blink?
         })

    new_state = %{state| graph: new_graph,
                         cursor_position: new_cursor_position }

    {:noreply, new_state, push: new_graph}
  end

  def handle_info(:blink, state) do

    new_blink = not state.cursor_blink?

    new_graph =
      Draw.blank_graph()
      |> Draw.background(state.frame, GUI.Colors.background())
      |> TextBoxDraw.render_text_grid(%{
           frame: state.frame,
           text: state.text,
           cursor_position: state.cursor_position,
           cursor_blink?: new_blink
         })

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

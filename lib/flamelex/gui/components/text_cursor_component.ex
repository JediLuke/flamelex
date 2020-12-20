defmodule Flamelex.GUI.Component.TextCursor do
  @moduledoc """
  Cursor is the blinky thing on screen that shows the user
  a) "where" we are in the file
  b) what mode we're in (by either blinking as a block, or being a straight line)
  """
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ComponentBehaviour


  @blink_ms trunc(500) # blink speed in hertz


  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(%{num: _n} = params) do # buffers need to keep track of cursors somehow, so we just use simple numbering

    GenServer.cast(self(), :start_blink)

    params |> Map.merge(%{
      # frame: params.frame,
      # grid_pos: nil,  # where we are in the file, e.g. line 3, column 5
      hidden?: false,                               # internal variable used to control blinking
      timer: nil,                                   # holds an erlang :timer for the blink
      original_coordinates: params.frame.top_left   # so we can track how we've moved around
    })
  end

  @impl Flamelex.GUI.ComponentBehaviour
  #TODO this is a deprecated version of render
  def render(%Frame{} = frame, params) do
    render(params |> Map.merge(%{frame: frame}))
  end


  def render(%{ref: %Buf{ref: buf_ref}, frame: %Frame{} = frame}) do
    block_dimensions = {_w, block_height} = cursor_box_dimensions()

    #notes
    # so, you would think that this lovely little equation...
    #   y_pos_of_cursor = frame.top_left.y+frame.margin.top-block_height
    # would be correct, considering Scenic renders blocks from the bottom-left for some reason..
    # however, it just looks weird! So, we move it down, a small offset

    cursor_y_aesthetic_offset = 3

    cursor_x_pos = frame.top_left.x+frame.margin.left
    cursor_y_pos = frame.top_left.y+frame.margin.top-block_height+cursor_y_aesthetic_offset

    Draw.blank_graph()
    |> Scenic.Primitives.rect(
          block_dimensions,
            id: buf_ref,
            translate: {cursor_x_pos, cursor_y_pos},
            fill: :ghost_white,
            hidden?: false)
  end

  defp cursor_box_dimensions do
    font = Flamelex.GUI.Fonts.primary(:font)
    size = Flamelex.GUI.Fonts.size()
    w = Flamelex.GUI.Fonts.monospace_font_width(font, size)
    h = Flamelex.GUI.Fonts.monospace_font_height(font, size)
    {w, h}
  end


  def rego_tag(%{ref: %Buf{ref: buf_ref}, num: num}) when is_integer(num) and num >= 1 do
    {:gui_component, {:text_cursor, buf_ref, num}}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_graph, _state}, action) do
    :ignore_action
  end

  def handle_cast(:start_blink, {graph, state}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {graph, new_state}}
  end


  @impl Scenic.Scene
  def handle_info(:blink, {graph, %{ref: %Buf{ref: buf_ref}} = state}) do

    new_state = %{state|hidden?: not state.hidden?}

    new_graph =
      graph
      |> Scenic.Graph.modify(
                buf_ref,
                &Scenic.Primitives.update_opts(&1,
                                      hidden: new_state.hidden?))

    {:noreply, {new_graph, new_state}, push: new_graph}
  end
end











# defmodule Flamelex.GUI.Component.BlinkingCursor do


#   def move(cursor_id, :right) do
#     cursor_id |> action(:move_right_one_column)
#   end



#   @impl Scenic.Scene
#   def handle_cast({:action, :move_right_one_column}, {state, graph}) do
#     %Dimensions{height: _height, width: width} =
#       state.frame.dimensions
#     %Coordinates{x: current_top_left_x, y: current_top_left_y} =
#       state.frame.top_left

#     new_state =
#       %{state|frame:
#           state.frame |> Frame.reposition(
#             x: current_top_left_x + width, #TODO this is actually just *slightly* too narrow for some reason
#             y: current_top_left_y)}

#     new_graph =
#       graph
#       |> Graph.modify(state.frame.id, fn %Scenic.Primitive{} = box ->
#            put_transform(box, :translate, {new_state.frame.top_left.x, new_state.frame.top_left.y})
#          end)

#     {:noreply, {new_state, new_graph}, push: new_graph}
#   end

#   @impl Scenic.Scene
#   def handle_cast({:action, :reset_position}, {state, graph}) do
#     new_state =
#       state.frame.top_left |> put_in(state.original_coordinates)

#     new_graph =
#       graph
#       |> Graph.modify(state.frame.id, fn %Scenic.Primitive{} = box ->
#            put_transform(box, :translate, {new_state.frame.top_left.x, new_state.frame.top_left.y})
#          end)

#     {:noreply, {new_state, new_graph}, push: new_graph}
#   end




#   # def handle_cast({:action, 'MOVE_LEFT_ONE_COLUMN'}, {state, graph}) do
#   #   {width, _height} = state.dimensions
#   #   {current_top_left_x, current_top_left_y} = state.top_left_corner

#   #   new_state =
#   #     %{state|top_left_corner: {current_top_left_x - width, current_top_left_y}}

#   #   new_graph =
#   #     graph
#   #     |> Graph.modify(:cursor, fn %Scenic.Primitive{} = box ->
#   #          put_transform(box, :translate, new_state.top_left_corner)
#   #        end)

#   #   {:noreply, {new_state, new_graph}, push: new_graph}
#   # end




#   # def handle_cast({:move, [top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}]}, {state, graph}) do
#   #   new_state =
#   #     %{state|top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}}

#   #   [%Scenic.Primitive{id: :cursor, styles: %{fill: color, hidden: hidden?}}] =
#   #     Graph.find(graph, fn primitive -> primitive == :cursor end)

#   #   new_graph =
#   #     graph
#   #     |> Graph.delete(:cursor)
#   #     |> rect({new_width, new_height},
#   #          id: :cursor,
#   #          translate: new_state.top_left_corner,
#   #          fill: color,
#   #          hidden?: hidden?)

#   #   {:noreply, {new_state, new_graph}, push: new_graph}
#   # end



#   # # --------------------------------------------------------
#   # def handle_cast(:stop_blink, %{graph: old_graph, timer: timer} = state) do
#   #   # hide the caret
#   #   new_graph =
#   #     old_graph
#   #     |> Graph.modify(:blinking_box, &update_opts(&1, hidden: true))

#   #   # stop the timer
#   #   case timer do
#   #     nil -> :ok
#   #     timer -> :timer.cancel(timer)
#   #   end

#   #   new_state =
#   #     %{state | graph: new_graph, hidden: true, timer: nil}

#   #   {:noreply, new_state, push: new_graph}
#   # end


# end

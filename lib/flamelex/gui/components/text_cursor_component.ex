defmodule Flamelex.GUI.Component.TextCursor do
  @moduledoc """
  Cursor is the blinky thing on screen that shows the user
  a) "where" we are in the file
  b) what mode we're in (by either blinking as a block, or being a straight line)
  """
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.Utils.TextCursor, as: CursorUtils


  @blink_ms trunc(500) # blink speed in hertz

  @valid_directions [:up, :down, :left, :right]

  # def redraw() do
  #   ProcessRegistry.find!({:cursor, n, {:gui_component, state.rego_tag}})
  #   |> GenServer.cast({:reposition, new_cursor}) #TODO change this to update
  # end


  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(%{num: _n} = params) do # buffers need to keep track of cursors somehow, so we just use simple numbering

    GenServer.cast(self(), :start_blink)

    starting_coords = CursorUtils.calc_starting_coordinates(params.frame)

    params |> Map.merge(%{
      #TODO do everything in terms of grids...
      # grid_pos: nil,  # where we are in the file, e.g. line 3, column 5
      #TODO make this original_coords
      original_coordinates: starting_coords,        # so we can track how we've moved around
      current_coords: starting_coords,
      hidden?: false,                               # internal variable used to control blinking
      override?: nil,                               # override lets us disable the blinking temporarily, for when we want to move the cursor
      timer: nil,                                   # holds an erlang :timer for the blink
      mode: :normal,                                # start out in normal mode, if insert mode we just have a line
    })
  end

  @impl Flamelex.GUI.ComponentBehaviour
  #TODO this is a deprecated version of render
  def render(%Frame{} = frame, params) do
    render(params |> Map.merge(%{frame: frame}))
  end


  def render(%{ref: buf_ref, current_coords: coords, mode: mode}) do
    Draw.blank_graph()
    |> Scenic.Primitives.rect(
          CursorUtils.cursor_box_dimensions(mode),
            id: buf_ref,
            translate: coords,
            fill: :ghost_white,
            hidden?: false)
  end


  def rego_tag(%{ref: ref, num: num}) when is_integer(num) and num >= 1 do
    # {:gui_component, {:buffer, {:file, _filename}}} = ref
    {:text_cursor, num, ref}
  end

  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_action(
  #         {graph, %{ref: buf_ref, current_coords: {_x, _y} = current_coords} = state},
  #         {:move_cursor, direction, distance})
  #           when direction in @valid_directions
  #           and distance >= 1 do

  #   CursorUtils.move(graph, state, %{
  #     current_coords: current_coords,
  #     direction: direction,
  #     distance: distance,
  #     buf_ref: buf_ref
  #   })
  # end

  def handle_action(
        {graph, %{ref: _buf_ref} = state},
        {:switch_mode, new_mode}) do
    {new_graph, new_state} = CursorUtils.switch_mode({graph, state}, new_mode)
    {:update_graph_and_state, {new_graph, new_state}}
  end


  def handle_cast(:start_blink, {graph, state}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {graph, new_state}}
  end

  def handle_cast({:move, details}, {graph, state}) do
    {new_graph, new_state} = CursorUtils.move_cursor({graph, state}, details)
    {:noreply, {new_graph, new_state}, push: new_graph}
  end

  def handle_cast({:reposition, new_coords}, {graph, state}) do
    {new_graph, new_state} = CursorUtils.reposition({graph, state}, new_coords)
    {:noreply, {new_graph, new_state}, push: new_graph}
  end

  @impl Scenic.Scene
  def handle_info(:blink, {graph, %{ref: _buf_ref} = state}) do
    {new_graph, new_state} = CursorUtils.handle_blink({graph, state})
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

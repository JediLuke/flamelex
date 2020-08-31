defmodule GUI.Component.Cursor do
  @moduledoc """
  Add a blinking text-input caret to a graph.

  graph
  |> Cursor.add_to_graph({x_coordinate, y_coordinate, width, height, color})
  """
  use Scenic.Component
  import Scenic.{Primitive, Primitives}
  alias Scenic.Graph
  require Logger
  use Franklin.Misc.CustomGuards

  @blink_ms trunc(500) # blink speed in hertz

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  # --------------------------------------------------------
  @doc false
  # def verify(%{
  #   top_left_corner: {_x, _y},
  #   dimensions: {_width, _height},
  #   color: _color,
  #   hidden?: _hidden?,
  #   id: _id
  # } = data), do: {:ok, data}
  # def verify(_), do: :invalid_data

  @impl Scenic.Component
  def verify(%Frame{} = frame), do: {:ok, frame}
  def verify(_else), do: :invalid_data

  # def move(right: {x, :columns}) do

  # end

  def move_right_one_column(pid) do
    GenServer.cast(pid, {:action, 'MOVE_RIGHT_ONE_COLUMN'})
  end

  def move(cursor_id, :right) do
    pid = cursor_id |> Utilities.ProcessRegistry.fetch_pid!()
    GenServer.cast(pid, {:action, 'MOVE_RIGHT_ONE_COLUMN'})
  end

  def init(%Frame{} = frame, _opts) do
    Logger.info "Initializing #{__MODULE__}..."

    Utilities.ProcessRegistry.register(frame.id)

    state = %{
      frame: frame,
      hidden?: false,
      timer: nil, # holds an erlang :timer for the blink
      original_position: {frame.coordinates.x, frame.coordinates.y} # so we can track how we've moved around
    }

    graph =
      Draw.blank_graph()
      |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
           id: frame.id,
           translate: {frame.coordinates.x, frame.coordinates.y},
           fill: :ghost_white,
           hidden?: false)

    GenServer.cast(self(), :start_blink)

    {:ok, {state, graph}, push: graph}
  end

  @impl Scenic.Component
  def handle_cast(:start_blink, {state, graph}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {new_state, graph}}
  end

  def handle_cast({:action, 'MOVE_RIGHT_ONE_COLUMN'}, {state, graph}) do
    %GUI.Structs.Dimensions{height: _height, width: width} = state.frame.dimensions
    %GUI.Structs.Coordinates{x: current_top_left_x, y: current_top_left_y} = state.frame.coordinates

    new_state =
      %{state|frame:
          state.frame |> Frame.reposition(
            x: current_top_left_x + width,
            y: current_top_left_y)}

    new_graph =
      graph
      |> Graph.modify(state.frame.id, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, {new_state.frame.coordinates.x, new_state.frame.coordinates.y})
         end)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  def handle_cast({:action, 'MOVE_LEFT_ONE_COLUMN'}, {state, graph}) do
    {width, _height} = state.dimensions
    {current_top_left_x, current_top_left_y} = state.top_left_corner

    new_state =
      %{state|top_left_corner: {current_top_left_x - width, current_top_left_y}}

    new_graph =
      graph
      |> Graph.modify(:cursor, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, new_state.top_left_corner)
         end)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  def handle_cast({:move, [top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}]}, {state, graph}) do
    new_state =
      %{state|top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}}

    [%Scenic.Primitive{id: :cursor, styles: %{fill: color, hidden: hidden?}}] =
      Graph.find(graph, fn primitive -> primitive == :cursor end)

    new_graph =
      graph
      |> Graph.delete(:cursor)
      |> rect({new_width, new_height},
           id: :cursor,
           translate: new_state.top_left_corner,
           fill: color,
           hidden?: hidden?)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  def handle_cast({:action, 'RESET_POSITION'}, {state, graph}) do
    new_state = %{state|top_left_corner: state.original_position}

    new_graph =
      graph
      |> Graph.modify(:cursor, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, state.original_position)
         end)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  # # --------------------------------------------------------
  # def handle_cast(:stop_blink, %{graph: old_graph, timer: timer} = state) do
  #   # hide the caret
  #   new_graph =
  #     old_graph
  #     |> Graph.modify(:blinking_box, &update_opts(&1, hidden: true))

  #   # stop the timer
  #   case timer do
  #     nil -> :ok
  #     timer -> :timer.cancel(timer)
  #   end

  #   new_state =
  #     %{state | graph: new_graph, hidden: true, timer: nil}

  #   {:noreply, new_state, push: new_graph}
  # end

  def handle_info(:blink, {state, graph}) do
    new_state = %{state|hidden?: not state.hidden?}

    new_graph =
      graph
      |> Graph.modify(state.frame.id, &update_opts(&1, hidden: new_state.hidden?))

    {:noreply, {new_state, new_graph}, push: new_graph}
  end


end

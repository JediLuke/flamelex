defmodule Flamelex.GUI.Component.Cursor do
  @moduledoc """
  Add a blinking text-input caret to a graph.

  graph
  |> Cursor.add_to_graph({x_coordinate, y_coordinate, width, height, color})
  """
  use Scenic.Component
  import Scenic.{Primitive, Primitives}
  alias Scenic.Graph
  require Logger
  use Flamelex.ProjectAliases

  @blink_ms trunc(500) # blink speed in hertz


  # --------------------------------------------------------
  # actions (Public API)


  def move(cursor_id, :right) do
    cursor_id |> action(:move_right_one_column)
  end

  # This is the generic action handler, it feeds through to the Reducer
  def action(cursor_id, params) do
    cursor_id
    |> Utilities.ProcessRegistry.fetch_pid!()
    |> GenServer.cast({:action, params})
  end


  # --------------------------------------------------------
  # Scenic.Component callbacks


  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  @impl Scenic.Component
  def verify(%Frame{} = frame), do: {:ok, frame}
  def verify(_else), do: :invalid_data


  # --------------------------------------------------------
  # init


  @impl Scenic.Scene
  def init(%Frame{} = frame, _opts) do
    # IO.puts "Initializing #{__MODULE__}..."

    Utilities.ProcessRegistry.register(frame.id)

    #TODO use a Struct here
    state = %{
      frame: frame,
      hidden?: false,
      timer: nil, # holds an erlang :timer for the blink
      original_coordinates: frame.top_left # so we can track how we've moved around
    }

    graph =
      Draw.blank_graph()
      |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
           id: frame.id,
           translate: {frame.top_left.x, frame.top_left.y},
           fill: :ghost_white,
           hidden?: false)

    GenServer.cast(self(), :start_blink)

    {:ok, {state, graph}, push: graph}
  end


  # --------------------------------------------------------
  # actions handlers


  @impl Scenic.Scene
  def handle_cast({:action, :move_right_one_column}, {state, graph}) do
    %Dimensions{height: _height, width: width} =
      state.frame.dimensions
    %Coordinates{x: current_top_left_x, y: current_top_left_y} =
      state.frame.top_left

    new_state =
      %{state|frame:
          state.frame |> Frame.reposition(
            x: current_top_left_x + width, #TODO this is actually just *slightly* too narrow for some reason
            y: current_top_left_y)}

    new_graph =
      graph
      |> Graph.modify(state.frame.id, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, {new_state.frame.top_left.x, new_state.frame.top_left.y})
         end)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  @impl Scenic.Scene
  def handle_cast({:action, :reset_position}, {state, graph}) do
    new_state =
      state.frame.top_left |> put_in(state.original_coordinates)

    new_graph =
      graph
      |> Graph.modify(state.frame.id, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, {new_state.frame.top_left.x, new_state.frame.top_left.y})
         end)

    {:noreply, {new_state, new_graph}, push: new_graph}
  end


  # --------------------------------------------------------
  # GenServer callbacks


  @impl Scenic.Scene
  def handle_cast(:start_blink, {state, graph}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {new_state, graph}}
  end

  @impl Scenic.Scene
  def handle_info(:blink, {state, graph}) do
    new_state = %{state|hidden?: not state.hidden?}

    new_graph =
      graph
      |> Graph.modify(state.frame.id, &update_opts(&1, hidden: new_state.hidden?))

    {:noreply, {new_state, new_graph}, push: new_graph}
  end




  # def handle_cast({:action, 'MOVE_LEFT_ONE_COLUMN'}, {state, graph}) do
  #   {width, _height} = state.dimensions
  #   {current_top_left_x, current_top_left_y} = state.top_left_corner

  #   new_state =
  #     %{state|top_left_corner: {current_top_left_x - width, current_top_left_y}}

  #   new_graph =
  #     graph
  #     |> Graph.modify(:cursor, fn %Scenic.Primitive{} = box ->
  #          put_transform(box, :translate, new_state.top_left_corner)
  #        end)

  #   {:noreply, {new_state, new_graph}, push: new_graph}
  # end




  # def handle_cast({:move, [top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}]}, {state, graph}) do
  #   new_state =
  #     %{state|top_left_corner: new_top_left_corner, dimensions: {new_width, new_height}}

  #   [%Scenic.Primitive{id: :cursor, styles: %{fill: color, hidden: hidden?}}] =
  #     Graph.find(graph, fn primitive -> primitive == :cursor end)

  #   new_graph =
  #     graph
  #     |> Graph.delete(:cursor)
  #     |> rect({new_width, new_height},
  #          id: :cursor,
  #          translate: new_state.top_left_corner,
  #          fill: color,
  #          hidden?: hidden?)

  #   {:noreply, {new_state, new_graph}, push: new_graph}
  # end



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


end

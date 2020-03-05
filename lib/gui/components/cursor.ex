defmodule GUI.Component.Cursor do
  @moduledoc """
  Add a blinking text-input caret to a graph.

  graph
  |> Cursor.add_to_graph({x_coordinate, y_coordinate, width, height, color})
  """
  use Scenic.Component, has_children: false
  import Scenic.{Primitive, Primitives}
  alias Scenic.Graph
  require Logger


  # blink speed in hertz
  @blink_ms trunc(500)


  def info(_data), do: ~s(Invalid data)

  # --------------------------------------------------------
  @doc false
  def verify(%{
    top_left_corner: {_x, _y},
    dimensions: {_width, _height},
    color: _color,
    hidden?: _hidden?,
    parent: %{
      pid: _parent_pid
    }
  } = data), do: {:ok, data}
  def verify(%{
    top_left_corner: {_x, _y},
    dimensions: {_width, _height}
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def move_right_one_column(pid) do
    GenServer.cast(pid, {:action, 'MOVE_RIGHT_ONE_COLUMN'})
  end

  def init(%{
    top_left_corner: {x, y},
    dimensions: {_width, _height},
    color: _color,
    hidden?: _hidden?,
    parent: %{
      pid: _parent_pid
    }
  } = data, _opts) do
    Logger.info "#{__MODULE__} initializing...#{inspect data}"

    GenServer.call(data.parent.pid, {:register, :cursor})

    state = data |> Map.merge(%{timer: nil, original_position: {x, y}}) # holds an erlang :timer for the blink
    graph = generate_graph(state)

    GenServer.cast(self(), :start_blink)

    {:ok, {state, graph}, push: graph}
  end
  def init(%{top_left_corner: {_x, _y}, dimensions: {_width, _height}} = data, opts) do
    init(data |> Map.merge(%{color: :ghost_white, hidden?: false}), opts)
  end

  def handle_cast(:start_blink, {state, graph}) do
    {:ok, timer} = :timer.send_interval(@blink_ms, :blink)
    new_state = %{state | timer: timer}
    {:noreply, {new_state, graph}}
  end

  def handle_cast({:action, 'MOVE_RIGHT_ONE_COLUMN'}, {state, graph}) do
    {width, _height} = state.dimensions
    {current_top_left_x, current_top_left_y} = state.top_left_corner

    new_state =
      %{state|top_left_corner: {current_top_left_x + width, current_top_left_y}}

    new_graph =
      graph
      |> Graph.modify(:cursor, fn %Scenic.Primitive{} = box ->
           put_transform(box, :translate, new_state.top_left_corner)
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

    # new_graph = generate_graph(new_state)

    new_graph =
      graph
      |> Graph.modify(:cursor, &update_opts(&1, hidden: new_state.hidden?))

    {:noreply, {new_state, new_graph}, push: new_graph}
  end

  defp generate_graph(%{
    top_left_corner: {x, y},
    dimensions: {width, height},
    color: color,
    hidden?: hidden?
  }) do
    Graph.build()
    |> rect({width, height},
         id: :cursor,
         translate: {x, y},
         fill: color,
         hidden?: hidden?)
  end
end

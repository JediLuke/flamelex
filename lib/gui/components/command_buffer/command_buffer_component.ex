defmodule GUI.Component.CommandBuffer do
  use Scenic.Component
  use Flamelex.CommonDeclarations
  alias GUI.Component.CommandBuffer.Reducer
  require Logger
  @moduledoc """
  This module is responsible for drawing the CommandBuffer.
  """

  @command_buffer_height 32

  @impl Scenic.Component
  def verify(%Frame{} = data), do: {:ok, data}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)


  ## Public API
  ## -------------------------------------------------------------------


  def draw(%Scenic.Graph{} = graph, viewport: %Dimensions{} = vp) do
    command_buffer =
      Frame.new(
        id: :command_buffer_frame,
        top_left_corner: Coordinates.new(
                x: 0,
                y: vp.height - @command_buffer_height),
        dimensions: Dimensions.new(
                width:  vp.width + 1, #TODO why do we need that +1?? Without it, you can definitely see a thin black line on the edge
                height: @command_buffer_height))

    graph
    |> add_to_graph(command_buffer)
  end

  def action(a) do
    GenServer.cast(__MODULE__, {:action, a})
  end

  def redraw(%Scenic.Graph{} = g) do
    GenServer.cast(__MODULE__, {:redraw, g})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def init(%Frame{} = state, _opts) do
    Logger.info "Initializing #{__MODULE__}..."

    #TODO search for if the process is already registered, if it is, engage recovery procedure
    Process.register(self(), __MODULE__) #TODO this should be gproc

    graph = Reducer.initialize(state)

    {:ok, {state, graph}, push: graph}
  end

  def handle_cast({:redraw, new_graph}, {state, _graph}) do
    {:noreply, {state, new_graph}, push: new_graph}
  end

  @impl Scenic.Scene
  def handle_cast({:action, action}, {state, graph}) do
    IO.puts "#{inspect action}"
    GUI.Component.CommandBuffer.Reducer.process({state, graph}, action)
    |> case do
         :ignore_action
            -> {:noreply, {state, graph}}
         {:update_state, new_state} when is_map(new_state)
            -> {:noreply, {new_state, graph}}
         {:update_graph, %Scenic.Graph{} = new_graph}
            -> {:noreply, {state, new_graph}, push: new_graph}
         {:update_state_and_graph, {new_state, %Scenic.Graph{} = new_graph}} when is_map(new_state)
            -> {:noreply, {new_state, new_graph}, push: new_graph}
       end
  end

  # @impl Scenic.Scene
  # def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
  #   Process.monitor(pid)

  #   new_component = {identifier, pid}
  #   new_ref_list = ref_list ++ [new_component]
  #   new_state = state |> Map.replace!(:component_ref, new_ref_list)

  #   {:reply, :ok, {new_state, graph}}
  # end

  # @impl Scenic.Scene
  # def handle_info({:DOWN, ref, :process, object, reason}, _state) do
  #   context = %{ref: ref, object: object, reason: reason}
  #   raise "Monitored process died. #{inspect context}"
  # end





  # def draw_command_buffer(graph) do
  #   graph
  #   |> GUI.Component.CommandBuffer.add_to_graph(%{
  #     id: :command_buffer,
  #     # top_left_corner: {0, h - command_buffer.data.height},
  #     top_left_corner: {0, 400},
  #     # dimensions: {w, command_buffer.data.height},
  #     dimensions: {400, 20},
  #     mode: :echo,
  #     text: "Welcome to Franklin. Press <f1> for help."
  #   })
  # end


end

defmodule GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour


  # @impl Flamelex.GUI.ComponentBehaviour
  # def mount(graph, params) do

  # end

  # @impl Flamelex.GUI.ComponentBehaviour
  # def render(params) do

  # end

  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_event(e) do

  # end
  @impl Scenic.Scene
  def handle_cast({:action, action}, {state, graph}) do
    case reducer().process({state, graph}, action) do
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






  defmodule GUI.Component.MenuBar.Reducer do

    def initialize(_params) do
      Draw.blank_graph()
    end
  end


  @impl Flamelex.GUI.ComponentBehaviour
  def reducer, do: __MODULE__.Reducer

  def draw(%Scenic.Graph{} = graph, viewport: %Dimensions{} = vp) do
    component_frame =
      Frame.new(
        id: :menu_bar_frame,
        top_left_corner: Coordinates.new(
                x: 20,
                # y: vp.height - @command_buffer_height),
                y: 20),
        dimensions: Dimensions.new(
                # width:  vp.width + 1, #TODO why do we need that +1?? Without it, you can definitely see a thin black line on the edge
                width: 100,
                # height: @command_buffer_height))
                height: 100)
        )

    graph
    |> add_to_graph(component_frame)
  end




  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def init(%Frame{} = state, _opts) do
    # IO.puts "Initializing #{__MODULE__}..."

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

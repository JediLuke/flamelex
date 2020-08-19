defmodule GUI.Component.CommandBuffer do
  use Scenic.Component, has_children: false
  use Franklin.Misc.CustomGuards
  alias GUI.Component.CommandBuffer.Reducer
  alias Structs.Buffer
  alias GUI.Structs.Frame
  require Logger


  ## Public API
  ## -------------------------------------------------------------------


  @doc """
  The `initialize` function is a function created as a convenience (it just
  makes sense to put it here) which requests the GUI.Root.Scene to add this
  Scenic.Component to the scene's graph.
  """
  def initialize(%Buffer{type: :command} = cmd_buf) do
    GUI.Scene.Root.action({:initialize_command_buffer, cmd_buf})
  end

  @doc ~s(Make the command buffer visible.)
  def activate, do: action 'ACTIVATE_COMMAND_BUFFER'


  ## Public functions, which are nonetheless more or less for internal use
  ## -------------------------------------------------------------------


  #TODO hide these Scenic functions behind a nice macro
  @impl Scenic.Component
  def verify(%Frame{} = data), do: {:ok, data}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  #NOTE: this is the one called by the RootReducer
  @impl Scenic.Scene
  def init(%Frame{} = state, _opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__) #TODO this should be gproc

    graph = Reducer.initialize(state)

    {:ok, {state, graph}, push: graph}
  end

  def action(a) do
    GenServer.cast(__MODULE__, {:action, a})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def handle_cast({:action, action}, {state, graph}) do
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

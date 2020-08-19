defmodule GUI.Component.CommandBuffer do
  use Scenic.Component, has_children: false
  use Franklin.Misc.CustomGuards
  alias GUI.Component.CommandBuffer.Reducer
  alias Structs.Buffer
  require Logger


  @impl Scenic.Component
  def verify(%{top_left_corner: {x, y}, dimensions: {w, h}} = data)
             when all_positive_integers(x, y, w, h), do: {:ok, data}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  def initialize(%Structs.Buffer{type: :command} = cmd_buf) do
    IO.puts "THIS SHOULD BE STARTING THE PROCESS..."
    GUI.Scene.Root.action({:initialize_command_buffer, cmd_buf})
  end

  #NOTE: this is the one called by the RootReducer
  @impl Scenic.Scene
  def init(data, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__) #TODO this should be grpoc

    state =
      data |> Map.merge(%{
        component_ref: [],
        opts: opts,
        text: "" #TODO show some prompt text when the echo buffer gets initialized
      })

    graph =
      Reducer.initialize(state)

    {:ok, {state, graph}, push: graph}
  end

  def activate, do: action 'ACTIVATE_COMMAND_BUFFER'

  def action(a) do
    IO.puts "ACTION??? #{inspect a}"
    GenServer.cast(__MODULE__, {:action, a})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def handle_cast({:action, action}, {state, graph}) do
    IO.puts "COMPONENT HANDLING ACTION #{inspect action}"
    case GUI.Component.CommandBuffer.Reducer.process({state, graph}, action) do
      :ignore_action ->
          {:noreply, {state, graph}}
      {:update_state, new_state} when is_map(new_state) ->
          {:noreply, {new_state, graph}}
      {:update_all, {new_state, %Scenic.Graph{} = new_graph}} when is_map(new_state) ->
          {:noreply, {new_state, new_graph}, push: new_graph}
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

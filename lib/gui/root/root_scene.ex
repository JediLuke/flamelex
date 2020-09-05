defmodule GUI.Scene.Root do #TODO rename to Root.Scene
  use Scenic.Scene
  require Logger


  ## public API
  ## -------------------------------------------------------------------


  def init(nil = _init_params, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache()

    scene = GUI.Structs.RootScene.new(opts)
    graph = GUI.Utilities.Draw.blank_graph()

    {:ok, {scene, graph}, push: graph}
  end

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})

  def redraw(%Scenic.Graph{} = g) do
    GenServer.cast(__MODULE__, {:redraw, g})
  end

  @doc """
  This is useful for debugging.
  """
  def pop_state, do: GenServer.call(__MODULE__, :pop_state)


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  @doc """
  Simply return the current state, and the %Scenic.Graph{}
  """
  def handle_call(:pop_state, {_pid, _ref}, {scene, graph}) do
    {:reply, :ok, {scene, graph}}
  end

  def handle_input(input, _context, {_scene, _graph} = state) do
    #TODO one day we might need to pass in the state too...
    #Flamelex.OmegaMaster.handle_input(state, input)
    Flamelex.OmegaMaster.handle_input(input)
    {:noreply, state}
  end
  #NOTE: Nice thing about the below way is it all happens sequentially
  # def handle_input(input, _context, {state, graph}) do
  #   #TODO here - spin this up into new process each time, off a centralized process which is holding state
  #   state = GUI.Input.EventHandler.process(state, input)
  #   {:noreply, {state, graph}}
  # end

  def handle_cast({:redraw, new_graph}, {scene, _graph}) do
    {:noreply, {scene, new_graph}, push: new_graph}
  end

  #TODO do this in a totally different process - right now, the entire GUI can crash just because an action wasn't found...
  # the main idea here is, we should have a totally different process, which
  # also holds this processes state. We route all inputs straight to that
  # other process, which has just as much knowledge of what's going on
  # (and in fact after this process boots & returns it's state, it has
  # effectively ceded control over it's own state), so it's totally able
  # to compute any changes to the GUI. It computes this new graph & simply
  # sends this process an update. Thus this process is just doing two things,
  # 1) spining up new event handler processes to respond to events and 2)
  # receiving GUI updates computed by the corresponding controller.
  def handle_cast({:action, action}, {scene, graph}) do
    case GUI.Root.Reducer.process({scene, graph}, action) do
      :ignore_action ->
          {:noreply, {scene, graph}}
      {:update_state, new_scene} when is_map(new_scene) ->
          {:noreply, {new_scene, graph}}
      {:update_all, {new_scene, %Scenic.Graph{} = new_graph}} when is_map(new_scene) ->
          {:noreply, {new_scene, new_graph}, push: new_graph}
    end
  end
end

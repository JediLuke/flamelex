defmodule GUI.Scene.Root do #TODO rename to Root.Scene
  use Scenic.Scene
  require Logger


  ## public API
  ## -------------------------------------------------------------------


  def init(nil = _init_params, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache()

    {state, graph} = GUI.Root.Reducer.initialize(opts)

    {:ok, {state, graph}, push: graph}
  end

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})


  # def redraw(%Scenic.Graph{} = g), do: GenServer.cast(__MODULE__, {:redraw, g})

  @doc """
  This is useful for debugging.
  """
  def pop_state, do: GenServer.call(__MODULE__, :pop_state)


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  @doc """
  Simply return the current state, and the %Scenic.Graph{}
  """
  def handle_call(:pop_state, {_pid, _ref}, {state, graph}) do
    {:reply, :ok, {state, graph}}
  end

  @doc """
  This function handles user input. All input for a scene routes through
  here.

  We use the state of the root scene (which may include global variables
  such as which mode we are in, and the recent input history, to allow
  chaining of keystrokes), as well as the input itself, to compute the new
  state, as well as fire off any secondary events or updates that this
  input requests.
  """
  def handle_input(input, _context, {state, graph}) do
    state = GUI.Input.EventHandler.process(state, input)
    {:noreply, {state, graph}}
  end

  # def handle_cast({:redraw, new_graph}, {state, _graph}) do
  #   {:noreply, {state, new_graph}, push: new_graph}
  # end

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
  def handle_cast({:action, action}, {state, graph}) do
    case GUI.Root.Reducer.process({state, graph}, action) do
      :ignore_action ->
          {:noreply, {state, graph}}
      {:update_state, new_state} when is_map(new_state) ->
          {:noreply, {new_state, graph}}
      {:update_all, {new_state, %Scenic.Graph{} = new_graph}} when is_map(new_state) ->
          {:noreply, {new_state, new_graph}, push: new_graph}
    end
  end
end

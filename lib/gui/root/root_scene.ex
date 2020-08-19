defmodule GUI.Scene.Root do #TODO rename to Root.Scene
  use Scenic.Scene
  require Logger
  alias GUI.Input.EventHandler
  # alias GUI.Component.CommandBuffer

  # @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash


  ## public API
  ## -------------------------------------------------------------------


  def init(nil = _init_params, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache()

    {state, graph} =
      initial_state(opts) #TODO I hate this
      |> GUI.Root.Reducer.initialize()

    {:ok, {state, graph}, push: graph}
  end

  def redraw(%Scenic.Graph{} = g), do: GenServer.cast(__MODULE__, {:redraw, g})

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})

  # def pop_state, do: GenServer.call(__MODULE__, :pop_state)


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  #TODO do this in a totally different process
  def handle_input(input, _context, {state, graph}) do
    state = EventHandler.process(state, input) #TODO do this in a totally different process
    {:noreply, {state, graph}}
  end

  #TODO this is fkin stupid...
  # def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
  #   Process.monitor(pid)

  #   new_component = {identifier, pid}
  #   #TODO ensure new component registry is unique!
  #   Logger.info "#{__MODULE__} registering component: #{inspect new_component}..."
  #   new_ref_list = ref_list ++ [new_component]
  #   new_state = state |> Map.replace!(:component_ref, new_ref_list)

  #   {:reply, :ok, {new_state, graph}}
  # end

  @doc """
  Simply return the current state, and the %Scenic.Graph{}

  This is used by GUI.Controller when it initializes - it calls this process
  to grab the state of the GUI, & it's able to "take charge" once the
  state is known.
  """
  def handle_call(:pop_state, {_pid, _ref}, {state, graph}) do
    {:reply, :ok, {state, graph}}
  end

  # def handle_cast({:redraw, new_graph}, {state, _graph}) do
  #   {:noreply, {state, new_graph}, push: new_graph}
  # end

  #TODO do this in a totally different process - right now, the entire GUI can crash just because an action wasn't found...
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

  #TODO possibly link to buffer processes once they are up

  # def handle_info({:DOWN, ref, :process, object, reason}, state) when reason in [:normal, :shutdown] do
  #   context = %{ref: ref, object: object}
  #   Logger.info "A component monitored by #{__MODULE__} ended normally. #{inspect context}"
  #   #TODO remove from component list
  #   {:noreply, state}
  # end

  # def handle_info({:DOWN, ref, :process, object, reason}, _state) do
  #   context = %{ref: ref, object: object, reason: reason}
  #   #TODO handle failures
  #   raise "Monitored process died. #{inspect context}"
  # end


  ## private functions
  ## -------------------------------------------------------------------


  defp initial_state(opts) do
    #TODO this should be a struct
    %{
      viewport: fetch_viewport_info(opts),

      # buffers - all the current buffers. Note that buffers will call back with their pids once the components are initialized
      # buffers: [
      #   %{
      #     id: :command_buffer,
      #     pid: nil,
      #     data: %{
      #       # height: 28
      #       height: Application.fetch_env!(:franklin, :bar_height)
      #     },
      #     state: %{
      #       text: "Welcome to Franklin. Press <f1> for help."
      #     }
      #   },
      #   %{
      #     id: {:text_editor, 1, :untitled},
      #     pid: nil,
      #     data: %{
      #       text_size: 24
      #     },
      #     active: :true
      #   }
      # ],

      # the input mode for Franklin
      input_mode: :control,

      # input history keeps track of inputs that have been entered by the user
      input_history: [],

      # holds the ID of the active buffer
      active_buffer: nil
    }
  end

  defp fetch_viewport_info(opts) do
    {:ok, %Scenic.ViewPort.Status{ size:
      { viewport_width, viewport_height }}} =
                          opts[:viewport]
                          |> Scenic.ViewPort.info()

    %{width: viewport_width, height: viewport_height}
  end
end

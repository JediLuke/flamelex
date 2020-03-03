defmodule GUI.Scene.Root do
  use Scenic.Scene
  require Logger
  alias GUI.Input.EventHandler
  alias GUI.Components.CommandBuffer

  @text_size 24
  @default_command_buffer_height 72
  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash

  def init(nil = _init_params, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache

    {:ok, %Scenic.ViewPort.Status{size: {viewport_width, viewport_height}}} =
      opts[:viewport] |> Scenic.ViewPort.info()

    #TODO ok this could probably be a struct...
    state = %{
      viewport: %{
        width: viewport_width,
        height: viewport_height,
      },
      component_ref: [], # contains pids of components, which call back & register themselves
      input_history: [], # holds all the input we've entered
      command_buffer: %{
        visible?: false
      }
    }

    graph =
      Scenic.Graph.build(font: @ibm_plex_mono, font_size: @text_size)
      |> CommandBuffer.add_to_graph(%{
           id: :command_buffer,
           top_left_corner: {0, viewport_height - @default_command_buffer_height},
           dimensions: {viewport_width, @default_command_buffer_height}
         })

    {:ok, {state, graph}, push: graph}
  end

  def redraw(%Scenic.Graph{} = g) do
    GenServer.cast(__MODULE__, {:redraw, g})
  end

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  def handle_input(input, _context, {state, graph}) do
    state = EventHandler.process(state, input)
    {:noreply, {state, graph}}
  end

  def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
    Process.monitor(pid)

    new_component = {identifier, pid}
    new_ref_list = ref_list ++ [new_component]
    new_state = state |> Map.replace!(:component_ref, new_ref_list)

    {:reply, :ok, {new_state, graph}}
  end

  def handle_cast({:redraw, new_graph}, {state, _graph}) do
    {:noreply, {state, new_graph}, push: new_graph}
  end

  def handle_cast({:action, action}, {state, graph}) do
    # try do
    #   new_state = state |> Reducer.apply_action(a)
    #   {:noreply, new_state, push: new_state.graph}
    # rescue
    #   FunctionClauseError -> #TODO need to be able to pattern match exclusively on Redux not found here
    #     Logger.error "Scene received an action `#{inspect a}` that has not been defined in Redux."
    #     {:noreply, state}
    # end
    case GUI.RootReducer.process({state, graph}, action) do
      {new_state, %Scenic.Graph{} = new_graph} when is_map(new_state) ->
          {:noreply, {new_state, new_graph}, push: new_graph}
      new_state when is_map(new_state) ->
          {:noreply, {new_state, graph}}
    end
  end

  def handle_info({:DOWN, ref, :process, object, reason}, _state) do
    context = %{ref: ref, object: object, reason: reason}
    raise "Monitored process died. #{inspect context}"
  end
end

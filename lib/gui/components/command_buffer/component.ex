defmodule GUI.Components.CommandBuffer do
  use Scenic.Component
  require Logger
  alias GUI.Components.CommandBuffer.Reducer

  @impl Scenic.Component
  def verify(%{id: _id, mode: :echo, top_left_corner: {_x, _y}, dimensions: {_w, _h}} = data), do: {:ok, data}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)

  @impl Scenic.Scene
  def init(data, opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    #TODO
    # GenServer.call(GUI.Scene.Root, {:register, :command_buffer})

    state =
      data |> Map.merge(%{
        component_ref: [],
        opts: opts
      })

    graph =
      Reducer.initialize(state)

    {:ok, {state, graph}, push: graph}
  end

  def action(a), do: GenServer.cast(__MODULE__, {:action, a})


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def handle_cast({:action, action}, {state, graph}) do
    case Reducer.process({state, graph}, action) do
      {new_state, %Scenic.Graph{} = new_graph} when is_map(new_state)
        -> {:noreply, {new_state, new_graph}, push: new_graph}
      new_state when is_map(new_state)
        -> {:noreply, {new_state, graph}}
    end
  end

  @impl Scenic.Scene
  def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
    Process.monitor(pid)

    new_component = {identifier, pid}
    new_ref_list = ref_list ++ [new_component]
    new_state = state |> Map.replace!(:component_ref, new_ref_list)

    {:reply, :ok, {new_state, graph}}
  end

  @impl Scenic.Scene
  def handle_info({:DOWN, ref, :process, object, reason}, _state) do
    context = %{ref: ref, object: object, reason: reason}
    raise "Monitored process died. #{inspect context}"
  end
end

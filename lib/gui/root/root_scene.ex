defmodule GUI.Root.Scene do
  use Scenic.Scene
  require Logger


  ## public API
  ## -------------------------------------------------------------------


  def init(nil = _init_params, _opts) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache()

    {:ok, %{}, push: GUI.Utilities.Draw.blank_graph()}
  end

  def redraw(%Scenic.Graph{} = graph) do
    GenServer.cast(__MODULE__, {:redraw, graph})
  end


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  def handle_input(input, _context, state) do
    Flamelex.OmegaMaster.handle_input(input)
    {:noreply, state}
  end

  def handle_cast({:redraw, new_graph}, state) do
    {:noreply, state, push: new_graph}
  end
end

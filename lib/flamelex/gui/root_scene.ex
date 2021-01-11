defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  alias Flamelex.GUI.Utilities.Draw


  # NOTE:
  # This Scenic.Scene contains the root graph. Re-drawing anything which
  # is rendered at the root level, required updating the state of this
  # process.  It is also responsible # for capturing user-input (this is
  # just how Scenic behaves), which then gets forwarded to FluxusRadix -
  # since FluxusRadix holds the global state, and we need that to lookup
  # what to do with this input, as illustrated below:
  #
  #     %RadixState{}  +  %Keystroke{}  ->   %Action{}
  #

  @doc """
  Force a top-level re-rendering of the GUI with a new %Scenic.Graph{}

  The only process who should be calling this is GUI.Controller
  """
  def redraw(%Scenic.Graph{} = graph) do
    GenServer.cast(__MODULE__, {:redraw, graph})
  end

  @impl Scenic.Scene
  def init(_params, _opts) do

    Process.register(self(), __MODULE__)
    Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    {:ok, push: Draw.blank_graph()}
  end

  @impl Scenic.Scene
  def handle_input(input, _context, state) do
    Flamelex.FluxusRadix.handle_user_input(input)
    {:noreply, state}
  end

  @impl Scenic.Scene
  def handle_cast({:redraw, new_graph}, state) do
    {:noreply, state, push: new_graph}
  end
end

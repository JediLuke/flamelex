defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  alias Flamelex.GUI.Utilities.Draw

  # This Scenic.Scene contains the root graph. In the end, to re-draw
  # to the screen, we must update this process. It is also responsible
  # for capturing user-input (this is just how Scenic behaves),
  # which then gets forwarded to OmegaMaster, so it can be handled within
  # the context of the global state.


  def init(_params, _opts) do
    IO.puts "#{__MODULE__} initializing..."

    Process.register(self(), __MODULE__)
    Flamelex.GUI.Initialize.load_custom_fonts_into_global_cache()

    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    {:ok, push: Draw.blank_graph()}
  end

  def redraw(%Scenic.Graph{} = graph) do
    GenServer.cast(__MODULE__, {:redraw, graph})
  end


  ## Scenic.Scene callbacks
  ## -------------------------------------------------------------------


  def handle_input(input, _context, state) do
    Flamelex.OmegaMaster |> GenServer.cast({:user_input, input})
    {:noreply, state}
  end

  def handle_cast({:redraw, new_graph}, state) do
    {:noreply, state, push: new_graph}
  end
end

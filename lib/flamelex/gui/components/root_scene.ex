defmodule Flamelex.API.GUI.RootScene do
  @moduledoc """
  This Scenic.Scene contains the root graph. It is also responsible for
  capturing user-input.
  """
  use Scenic.Scene
  alias Flamelex.Utilities.ProcessRegistry
  alias Flamelex.API.GUI.Utilities.Draw


  def init(nil = _init_params, _opts) do
    IO.puts "#{__MODULE__} initializing..."

    ProcessRegistry.gproc_register(__MODULE__)
    Flamelex.API.GUI.Initialize.load_custom_fonts_into_global_cache()

    #NOTE: `GUI.Controller` will boot next & take control of the scene,
    #      so we just need to initialize it with *something*
    {:ok, push: Draw.blank_graph()}
  end

  def redraw(%Scenic.Graph{} = graph) do
    ProcessRegistry.find!(__MODULE__)
    |> GenServer.cast({:redraw, graph})
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

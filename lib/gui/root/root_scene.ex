defmodule Flamelex.GUI.Root.Scene do
  use Scenic.Scene


  ## public API
  ## -------------------------------------------------------------------


  def init(nil = _init_params, _opts) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)

    GUI.Initialize.load_custom_fonts_into_global_cache()


    #TODO introduce a concept here of layers - make each layer an explicit entry in the main graph, which stack on top of eachother
    layers = [
      {0, GUI.Utilities.Draw.blank_graph()}
    ]


    {:ok, push: layers |> List.first()}
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

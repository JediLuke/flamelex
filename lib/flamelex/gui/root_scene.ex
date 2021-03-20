defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  use Flamelex.GUI.ScenicEventsDefinitions
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

  # Scenic sends us lots of keypresses etc... easiest to just filter them
  # out right where they're detected, otherwise they clog up things like
  # keystroke history etc...
  @ignorable_input_events [
    :viewport_enter,
    :viewport_exit,
    :key # we use `:codepoint` for characters, some :keys are specifically matched
  ]

  # ignore all :key events, except these...
  @matched_keys [@escape_key, @backspace_key]

  # accept the matched keys, before we ignore all other keys...
  def handle_input(input, _context, state) when input in @matched_keys do
    #TODO we want to be able to hold dosn keys like backspace & trigger events while it's held
    Flamelex.Fluxus.handle_user_input(input)
    {:noreply, state}
  end

  @impl Scenic.Scene
  def handle_input({event, _details}, _context, state)
    when event in @ignorable_input_events do
      # ignore...
      {:noreply, state}
  end

  # handle all unignored input...
  def handle_input(input, _context, state) do
    Flamelex.Fluxus.handle_user_input(input)
    {:noreply, state}
  end

  @impl Scenic.Scene
  def handle_cast({:redraw, new_graph}, state) do
    {:noreply, state, push: new_graph}
  end
end

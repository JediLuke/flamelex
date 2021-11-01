defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  use Flamelex.GUI.ScenicEventsDefinitions

  import Scenic.Primitives
  import Scenic.Components
  require Logger
  # NOTE:
  # This Scenic.Scene contains the root graph. Re-drawing anything which
  # is rendered at the root level, required updating the state of this
  # process.  It is also responsible for capturing user-input (this is
  # just how Scenic behaves), which then gets forwarded to FluxusRadix -
  # since FluxusRadix holds the global state, and we need that to lookup
  # what to do with this input, as illustrated below:
  #
  #     %RadixState{}  +  %Keystroke{}  ->  %Action{}
  #


  # @impl Scenic.Scene
  # def init(scene, _params, _opts) do
  #   Process.register(self(), __MODULE__)
  #   {:ok, scene}
  # end

#   @graph Scenic.Graph.build()
#   |> group( fn graph ->
#   graph
#   |> text( "Count: " <> inspect(@initial_count), id: :count )
#   |> button( "Click Me", id: :btn, translate: {0, 30} )
#   end,
#   translate: {100, 100}
# )

# defp graph(), do: @graph



  @impl Scenic.Scene
  def init(scene, _params, _opts) do

    Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

    graph = 
    Scenic.Graph.build()
    # |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    # |> Scenic.Primitives.rect({80, 80}, fill: :green,  translate: {140, 140})

    scene = scene |> assign(graph: graph) |> push_graph(graph)
    
    capture_input(scene, [:key])
    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    {:ok, scene}
  end

  # def init(scene, _params, _opts) do
  #   scene =
  #     scene
  #     |> assign( count: 0 )
  #     |> push_graph( graph() )
  #   {:ok, scene}
  # end



  # @impl Scenic.Scene
  # def handle_event( {:click, :btn}, _, %{assigns: %{count: count}} = scene ) do
  #   count = count + 1

  #   # modify the graph to show the current click count
  #   graph =
  #     graph()
  #     |> Scenic.Graph.modify(:count, &text(&1, "Count: " <> inspect(count)))

  #   # update the count and push the modified graph
  #   scene =
  #     scene
  #     |> assign( count: count )
  #     |> push_graph( graph )

  #   # return the updated scene
  #   { :noreply, scene }
  # end

  # handle all other (not-ignored) input...
  def handle_event(input, _context, scene) do
    IO.puts "SOME NON IGNORED INPUT #{inspect input}"
    # Flamelex.Fluxus.handle_user_input(input)
    {:noreply, scene}
  end



  # # Scenic sends us lots of keypresses etc... easiest to just filter them
  # # out right where they're detected, otherwise they clog up things like
  # # keystroke history etc...
  # @ignorable_input_events [
  #   :viewport_enter,
  #   :viewport_exit,
  #   :key # we use `:codepoint` for characters, some :keys are specifically matched e.g. backspace
  # ]

  # # ignore all :key events, except these...
  # @matched_keys [@escape_key, @backspace_key, @enter_key]

  # # match on these specific keys here, above the `ignorable_input`, so they're not ignored
  # def handle_input(input, _context, scene) when input in @matched_keys do
  #   IO.puts "MATCHED KEYS #{inspect input}"
  #   #TODO we want to be able to hold down keys like backspace & trigger events while it's held
  #   Flamelex.Fluxus.handle_user_input(input)
  #   {:noreply, scene}
  # end

  # @impl Scenic.Scene
  # def handle_input({event, _details}, _context, scene)
  #   when event in @ignorable_input_events do
  #     # ignore...
  #     IO.puts "IGNORESD???"
  #     {:noreply, scene}
  # end

  def handle_input({:key, {key, @key_released, []}}, _context, scene) do
    Logger.debug "#{__MODULE__} `key_released` for keypress: #{inspect key}"
    {:noreply, scene}
  end

  # If this works, she's a pearla!
  def handle_input({:key, {key, @key_held, []}} = input, context, scene) do
    # test if the `same key, just with a normal `key_pressed` event, is valid input
    equivalent_key_pressed_input = {:key, {key, @key_pressed, []}}
    if Enum.member?(@valid_text_input_characters, equivalent_key_pressed_input) do
      #NOTE: It's vitally important we remember to recursively call
      #      ourselves with the *equivalent_key_pressed_input* here :P
      handle_input(equivalent_key_pressed_input, context, scene)
    else
      Logger.warn "#{__MODULE__} the key: #{inspect key} is being held, however `key_pressed` not valid"
      {:noreply, scene}
    end
  end


  # # handle all other (not-ignored) input...
  def handle_input(input, context, scene) do
    # IO.puts "SOME NON IGNORED INPUT #{inspect input}"

    ##TODO it's simpler to route these different right now.

    # call Flamelex.Fluxus.UserInput.

    # This is an example of the "state-centered" approach - we keep
    # wanting to store things in the scene - maybe I should just put everything
    # in here lol

    # The whole idea of 'fluxus' is to seperate out the state of your
    # application, from the state of your Scenic GUI processes

    #TODO this is one area of quandary - either I spin up a new process
    # to handle everything (nice security), but then I have to wait here
    # for a callback. Or, if I don't wait, then I have to give up my
    # ability to mutate the scene here.

    # Maybe how this should work is - instead of messaging a GenServer
    # which holds the root state, we just start a process, which fetches
    # a copy of the root state inside itself
    Flamelex.Fluxus.handle_user_input(%{
      source: __MODULE__,
      context: context,
      input: input
    })
    {:noreply, scene}
  end

  # @impl Scenic.Scene
  #NOTE: The only process which should be sending us these is GUI.Controller
  def handle_cast({:redraw, new_graph}, scene) do
    Logger.debug "-- re-drawing the RootScene --"
    new_scene =
      scene
      |> assign(graph: new_graph)
      |> push_graph(new_graph)
    {:noreply, new_scene}
  end

end

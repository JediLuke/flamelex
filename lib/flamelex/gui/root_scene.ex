defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  use ScenicWidgets.ScenicEventsDefinitions
  import Scenic.Primitives
  import Scenic.Components
  alias Flamelex.GUI.Component.Layer
  require Logger
  # NOTE:
  # This Scenic.Scene contains the root graph. Re-drawing anything which
  # is rendered at the root level, required updating the state of this
  # process.  It is also responsible for capturing user-input (this is
  # just how Scenic behaves), which then gets forwarded to FluxusRadix -
  # since FluxusRadix holds the global state, and we need that to lookup
  # what to do with this input, as illustrated below:
  #
  #     %{}  +  %Keystroke{}  ->  %Action{}
  #
  #
  #TODO document the layers system
  # root scene doesn't subscribe to changes, it just spins up 7 layer processes
  # these _do_ subscribe to changes, specifically, just the change in their layer ;)
  # Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)


  # Scenic sends us lots of keypresses etc... easiest to just filter them
  # out right where they're detected (i.e. here), otherwise they clog up
  # things like keystroke history etc...
  @ignorable_input_events [
    :viewport_enter,
    :viewport_exit,
  ]


  @impl Scenic.Scene
  def init(init_scene, _params, opts) do

    Process.register(self(), __MODULE__)

    opts = opts |> set_theme(Flamelex.GUI.Utils.Theme.default())

    radix_state = Flamelex.Fluxus.RadixStore.get()

    layer_1_graph = Scenic.Graph.build() # primary_app()
                    # |> Flamelex.GUI.Renseijin.add_to_graph  
    layer_2_graph = Scenic.Graph.build()
                    |> Flamelex.GUI.Component.MenuBar.add_to_graph(%{
                        viewport: init_scene.viewport,
                        state: radix_state.menu_bar})
    layer_3_graph = Scenic.Graph.build()
                    |> Flamelex.GUI.KommandBuffer.add_to_graph(%{
                        viewport: init_scene.viewport
                    })
    layer_4_graph = Scenic.Graph.build()

    init_graph = Scenic.Graph.build()
    |> Layer.add_to_graph(%{id: :one, graph: layer_1_graph})
    |> Layer.add_to_graph(%{id: :two, graph: layer_2_graph})
    |> Layer.add_to_graph(%{id: :three, graph: layer_3_graph})
    |> Layer.add_to_graph(%{id: :four, graph: layer_4_graph})

    # We update a few details in the RadixStore which are force-refreshed
    # due to this process starting up
    Flamelex.Fluxus.RadixStore.initialize(
        graph: init_graph,
        layers: [{:one, layer_1_graph},
                 {:two, layer_2_graph},
                 {:three, layer_3_graph},
                 {:four, layer_4_graph}],
        viewport: init_scene.viewport)

    new_scene = init_scene
    |> assign(graph: init_graph)
    |> push_graph(init_graph)

    # capture_input(scene, [:key])
    # request_input(new_scene, [:viewport, :cursor_button, :cursor_scroll, :key])
    request_input(new_scene, [:cursor_button, :cursor_scroll, :key])

    {:ok, new_scene}
  end


  def handle_call(:get_viewport, _from, scene) do
    {:reply, {:ok, scene.viewport}, scene}
  end

  #NOTE: The only process which should be sending us these is GUI.Controller
  def handle_call({:redraw, new_graph}, _from, scene) do #TODO maybe use _from to assert the caller, that would be cool
    Logger.debug "#{__MODULE__} re-drawing the RootScene..."
    new_scene = scene
      |> assign(graph: new_graph)
      |> push_graph(new_graph)
    {:reply, :ok, new_scene}
  end

  def handle_input({:viewport, {:reshape, {new_width, new_height} = new_dimensions}}, context, scene) do # e.g. of new_dimensions: {1025, 818}
      Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

      raise "can't handle resizing right now"
      # new_scene = scene
      # |> assign(frame: Frame.new(
      #                    pin: {0, 0},
      #                    orientation: :top_left,
      #                    size: {new_width, new_height},
      #                    #TODO deprecate below args
      #                    top_left: Coordinates.new(x: 0, y: 0), # this is a guess
      #                    dimensions: Dimensions.new(width: new_width, height: new_height)))
      # |> render_push_graph()

      {:noreply, scene}
  end


  def handle_input({event, _details}, _context, scene)
    when event in @ignorable_input_events do
      Logger.debug "#{__MODULE__} ignoring event: #{inspect event}"
      {:noreply, scene}
  end

  def handle_input({:key, {key, @key_released, []}}, _context, scene) do
    #Logger.debug "#{__MODULE__} `key_released` for keypress: #{inspect key}"
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

  def handle_input(input, context, scene) do
    #Logger.debug "#{__MODULE__} recv'd some (non-ignored) input: #{inspect input}"
    Flamelex.Fluxus.input(input)
    {:noreply, scene}
  end

  defp set_theme(opts, new_theme), do: Keyword.replace(opts, :theme, new_theme)

end

defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  use ScenicWidgets.ScenicEventsDefinitions
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
  #     %{}  +  %Keystroke{}  ->  %Action{}
  #


  @impl Scenic.Scene
  def init(init_scene, _params, _opts) do

    Process.register(self(), __MODULE__)

    init_graph = Flamelex.Fluxus.RadixStore.get() |> render()

    new_scene = init_scene
    |> assign(graph: init_graph)
    |> push_graph(init_graph)

    Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

    Flamelex.Fluxus.RadixStore.initialize(graph: init_graph,
                                       viewport: init_scene.viewport)

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

  def handle_info({:radix_state_change, %{root: %{graph: new_root_graph}}}, %{assigns: %{graph: current_graph}} = scene)
    when current_graph != new_root_graph do
      Logger.debug "#{__MODULE__} RadixState changed, re-drawing the RootScene..."
      new_scene = scene
        |> assign(graph: new_root_graph)
        |> push_graph(new_root_graph)
      {:noreply, new_scene |> assign(graph: new_root_graph)}
  end

  def handle_info({:radix_state_change, _new_radix_state}, scene) do
    Logger.debug "#{__MODULE__} ignoring a RadixState change..."
    {:noreply, scene}
  end


  # def handle_input({:viewport, {:reshape, {new_width, new_height} = new_dimensions}}, context, scene) do # e.g. of new_dimensions: {1025, 818}
  #     Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

  #     new_scene = scene
  #     |> assign(frame: Frame.new(
  #                        pin: {0, 0},
  #                        orientation: :top_left,
  #                        size: {new_width, new_height},
  #                        #TODO deprecate below args
  #                        top_left: Coordinates.new(x: 0, y: 0), # this is a guess
  #                        dimensions: Dimensions.new(width: new_width, height: new_height)))
  #     |> render_push_graph()
  #     {:noreply, scene}
  # end

  # Scenic sends us lots of keypresses etc... easiest to just filter them
  # out right where they're detected, otherwise they clog up things like
  # keystroke history etc...
  @ignorable_input_events [
    :viewport_enter,
    :viewport_exit,
  ]

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
    Flamelex.Fluxus.handle_user_input(%{
        source: __MODULE__,
        context: context,
        input: input })
    {:noreply, scene}
  end



  def render(%{root: %{graph: nil}} = _radix_state) do
    Scenic.Graph.build()
    #TODO here get MenuBar etc
  end

  def render(%{root: %{graph: %Scenic.Graph{} = root_graph}} = _radix_state) do
    root_graph
  end
end

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


  @impl Scenic.Scene
  def init(init_scene, _params, opts) do

    Process.register(self(), __MODULE__)

    opts = opts |> set_theme(Flamelex.GUI.Utils.Theme.default())

    layer_1_graph = primary_app()
    layer_2_graph = menu_bar(init_scene)
    layer_3_graph = kommander()
    layer_4_graph = Scenic.Graph.build()

    layers = [
      {:one, layer_1_graph},
      {:two, layer_2_graph},
      {:three, layer_3_graph},
      {:four, layer_4_graph}
    ]

    init_graph = Scenic.Graph.build()
    # |> Layer.add_to_graph(%{id: :base,  graph: Scenic.Graph.build()})
    |> Layer.add_to_graph(%{id: :one, graph: layer_1_graph})
    |> Layer.add_to_graph(%{id: :two, graph: layer_2_graph})
    |> Layer.add_to_graph(%{id: :three, graph: layer_3_graph})
    |> Layer.add_to_graph(%{id: :four, graph: layer_4_graph})



    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :one})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :two})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :three})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :four})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :five})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :six})
    # |> Scenic.Primitives.group(fn graph -> graph end, id: {:layer, :seven})

    new_scene = init_scene
    |> assign(graph: init_graph)
    #REMINDER: We need to track these, so that we can detect changes
    # |> assign(layer_1: Scenic.Graph.get(init_graph, {:layer, :one}))
    # |> assign(layer_2: Scenic.Graph.get(init_graph, {:layer, :two}))
    # |> assign(layer_3: Scenic.Graph.get(init_graph, {:layer, :three}))
    # |> assign(layer_4: Scenic.Graph.get(init_graph, {:layer, :four}))
    # |> assign(layer_5: Scenic.Graph.get(init_graph, {:layer, :five}))
    # |> assign(layer_6: Scenic.Graph.get(init_graph, {:layer, :six}))
    # |> assign(layer_7: Scenic.Graph.get(init_graph, {:layer, :seven}))
    |> push_graph(init_graph)

    #TODO ok, changes for the layer system
    # root scene doesn't subscribe to changes, it just spins up 7 layer processes
    # these _do_ subscribe to changes, specifically, just the change in their layer ;)
    # Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

    Flamelex.Fluxus.RadixStore.initialize(graph: init_graph,
                                         layers: layers,
                                       viewport: init_scene.viewport)

    # capture_input(scene, [:key])
    # request_input(new_scene, [:viewport, :cursor_button, :cursor_scroll, :key])
    request_input(new_scene, [:cursor_button, :cursor_scroll, :key])

    {:ok, new_scene}
  end

  def primary_app do
    Scenic.Graph.build()
  end

  def menu_bar(%{viewport: %{size: {vp_width, _vp_height} = _vp_size}} = scene) do

    # default_map = %{
    #   "Flamelex" => %{
    #     "temet nosce" => {Flamelex, :temet_nosce, []},
    #     "show cmder" => {Flamelex.API.CommandBuffer, :show, []}
    #   },
    #   "Memex" => %{
    #     "open" => {Flamelex.API.MemexWrap, :open, []},
    #     "random quote" => {Flamelex.Memex, :random_quote, []},
    #     "journal" => {Flamelex.MemexWrap.Journal, :now, []}
    #   },
    #   "GUI" => %{}, #TODO auto-generate it from the GUI file
    #   "Buffer" => %{
    #     "open README" => {Flamelex.API.Buffer, :open!, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
    #     # "close" => {Flamelex.API.Buffer, :close, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
    #     "close" => fn -> Buffer.active_buffer() |> Buffer.close() end
    #   },
    #   "DevTools" => %{},
    #   "Help" => %{
    #     "Getting Started" => nil,
    #     "About" => nil
    #   },
    # }


    #TODO this has to go into radix, so we can update it as needed.
    menu_map = [
      {"Buffer",
       [
         {"new", &Flamelex.API.Buffer.new/0},
        #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
         {"save", &Flamelex.API.Buffer.save/0},
         {"close", &Flamelex.API.Buffer.close/0}
       ]},
      {"Memex",
       [
         {"open", &Flamelex.API.Memex.open/0},
         {"close", &Flamelex.API.Memex.close/0},
       ]}
      # {"Help", [
          # {"About QuillEx", &Flamelex.API.Misc.makers_mark/0}]},
    ]

    # @menubar %{height: 60}
    menubar = %{height: 60}

    {:ok, ibm_plex_mono_metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")

    Scenic.Graph.build()
    |> ScenicWidgets.MenuBar.add_to_graph(
      %{
        frame:
        ScenicWidgets.Core.Structs.Frame.new(
            pin: {0, 0},
            size: {vp_width, menubar.height}
          ),
        menu_opts: menu_map,
        item_width: {:fixed, 180},
        font: %{
          name: :ibm_plex_mono,
          size: 36,
          metrics: ibm_plex_mono_metrics
        },
        sub_menu: %{
          height: 40,
          font: %{size: 22}
        }
      },
      id: :menu_bar
    )
    # |> Scenic.Primitives.rect({400, 200}, t: {300, 400}, fill: :green)
  end

  def kommander do
    Scenic.Graph.build()
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

  defp set_theme(opts, new_theme), do: Keyword.replace(opts, :theme, new_theme)

end

defmodule Flamelex.GUI.RootScene do
   @moduledoc false
   use Scenic.Scene
   use ScenicWidgets.ScenicEventsDefinitions
   import Scenic.Primitives
   import Scenic.Components
   # alias Flamelex.GUI.Component.Layer
   require Logger
   alias ScenicWidgets.Core.Structs.Frame
   alias ScenicWidgets.Core.Utils.FlexiFrame


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

   # This trick to this module is the %Layer{} component which we wrap all
   # the graphs in. When a layer needs to change, it get's picked up by the
   # %Layer{} component, not the RootScene


   @ignorable_input_events [
      :viewport_enter,
      :viewport_exit,
   ]


   def init(init_scene, _args, opts) do
      Logger.debug("#{__MODULE__} initializing...")

      Flamelex.Fluxus.RadixStore.put_viewport(init_scene.viewport)
      init_theme = ScenicWidgets.Utils.Theme.get_theme(opts) #TODO put this in radix state? gui.theme?

      radix_state = Flamelex.Fluxus.RadixStore.get()

      # NOTE `graphcake` contains the graphs of all the Layers, & the combined Graph
      # {:ok, graphcake} = 

      # We update a few details in the RadixStore which are
      # force-refreshed due to this process starting up
      {:ok, root_graph} = render_layers(radix_state)

      Flamelex.Fluxus.RadixStore.put_root_graph(graph: root_graph)
      #    layers: [
      #       {:one, graphcake.layer_1},
      #       {:two, graphcake.layer_2},
      #       {:three, graphcake.layer_3},
      #       {:four, graphcake.layer_4}
      #    ]
      # )

      new_scene = init_scene
      |> assign(graph: root_graph)
      |> push_graph(root_graph)

      request_input(new_scene, [:cursor_button, :cursor_scroll, :key])

      {:ok, new_scene}
   end

   # def handle_call(:get_viewport, _from, scene) do
   #    {:reply, {:ok, scene.viewport}, scene}
   # end

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



   def render_layers(radix_state) do
         
      # layer_1_graph = Flamelex.GUI.Layers.LayerOne.render(radix_state)
      # layer_2_graph = Flamelex.GUI.Layers.LayerTwo.render(radix_state)
      # layer_3_graph = Flamelex.GUI.Layers.LayerThree.render(radix_state)
      # layer_4_graph = Scenic.Graph.build()

      #TODO add a layer 0, to render the Renseijin
      #NOTE: The ids of these layers needs to mtch the keys in the RadiXState.root.layer_list
      full_graph =
         Scenic.Graph.build()
         |> Flamelex.GUI.Component.Layer.add_to_graph(%{
               layer_module: Flamelex.GUI.Layers.LayerOne,
               radix_state: radix_state
         }, id: :one)
         |> Flamelex.GUI.Component.Layer.add_to_graph(%{
               layer_module: Flamelex.GUI.Layers.LayerTwo,
               radix_state: radix_state
         }, id: :two)
         |> Flamelex.GUI.Component.Layer.add_to_graph(%{
               layer_module: Flamelex.GUI.Layers.LayerThree,
               radix_state: radix_state
         }, id: :three)

      #NOTE: Although `full_graph` is a complete graph containing all the
      #      layers (and this is the %Graph{} we will render), we need to
      #      keep the other layer graphs in memory so that we can compare
      #      and update them with any changes

      # graph_layercake = %{
      #    full: full_graph,
      #    # layer_1: layer_1_graph,
      #    # layer_2: layer_2_graph,
      #    # layer_3: layer_3_graph,
      #    # layer_4: layer_4_graph,
      # }

      # {:ok, graph_layercake}
      {:ok, full_graph}
   end

end

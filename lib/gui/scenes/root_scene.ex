defmodule Flamelex.GUI.RootScene do
   @moduledoc false
   use Scenic.Scene
   use ScenicWidgets.ScenicEventsDefinitions
   import Scenic.Primitives
   import Scenic.Components
   alias ScenicWidgets.Core.Structs.Frame
   alias ScenicWidgets.Core.Utils.FlexiFrame
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

   # This trick to this module is the %Layer{} component which we wrap all
   # the graphs in. When a layer needs to change, it get's picked up by the
   # %Layer{} component, not the RootScene



   def init(init_scene, _args, opts) do
      Logger.debug("#{__MODULE__} initializing...")

      #TODO we should return the radix_state here to save us from having to fetch it again in like 5 lines time
      Flamelex.Fluxus.RadixStore.put_viewport(init_scene.viewport)
      init_theme = ScenicWidgets.Utils.Theme.get_theme(opts) #TODO put this in radix state? gui.theme?
      radix_state = Flamelex.Fluxus.RadixStore.get()
   
      # We update a few details in the RadixStore which are
      # force-refreshed due to this process starting up
      {:ok, root_graph} = render_layers(radix_state)

      Flamelex.Fluxus.RadixStore.put_root_graph(graph: root_graph)

      new_scene = init_scene
      |> assign(graph: root_graph)
      |> push_graph(root_graph)

      request_input(new_scene, [:viewport, :cursor_button, :cursor_scroll, :key])

      {:ok, new_scene}
   end

   # def handle_call(:get_viewport, _from, scene) do
   #    {:reply, {:ok, scene.viewport}, scene}
   # end

   def handle_input({:viewport, {:enter, _coords}}, context, scene) do
      Logger.debug "#{__MODULE__} ignoring `:viewport_enter`..."
      {:noreply, scene}
   end

   def handle_input({:viewport, {:exit, _coords}}, context, scene) do
      Logger.debug "#{__MODULE__} ignoring `:viewport_exit`..."
      {:noreply, scene}
   end

   def handle_input({:viewport, {:reshape, {new_width, new_height} = new_dimensions}}, context, scene) do # e.g. of new_dimensions: {1025, 818}
      Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

      new_viewport = %{scene.viewport|size: new_dimensions}
      Flamelex.Fluxus.RadixStore.update_viewport(new_viewport)

      {:noreply, %{scene|viewport: new_viewport}}
   end

   def handle_input({:key, {key, @key_released, _opts}}, _context, scene) do
      # Ignore key releases
      #Logger.debug "#{__MODULE__} `key_released` for keypress: #{inspect key}"
      {:noreply, scene}
   end

   def handle_input({:key, {key, @key_held, []}} = input, context, scene) do
      # If we hold down any kind of valid text input, pretend we just pressed it again
      # # If this works, she's a pearla!

      # the list of keys we can hold down and have the action repeat
      hold_downable_keys = @valid_text_input_characters ++ [@backspace_key]

      equivalent_key_press = {:key, {key, @key_pressed, []}}
      if Enum.member?(hold_downable_keys, equivalent_key_press) do
         # NOTE: It's vitally important we remember to recursively call
         # ourselves with the *equivalent_key_pressed_input* here :P
         handle_input(equivalent_key_press, context, scene)
      else
         Logger.warn "#{__MODULE__} the key: #{inspect key} is being held, however `key_pressed` not valid"
         {:noreply, scene}
      end
   end

   def handle_input(input, context, scene) do
      Logger.debug "#{__MODULE__} recv'd some (non-ignored) input: #{inspect input}"
      Flamelex.Fluxus.input(input)
      {:noreply, scene}
   end

   def render_layers(radix_state) do
      full_graph =
         Scenic.Graph.build()
         |> Flamelex.GUI.Component.Layer.add_to_graph(%{
            layer_module: Flamelex.GUI.Layers.LayerZero,
            radix_state: radix_state
         }, id: :zero)
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

      {:ok, full_graph}
   end

end

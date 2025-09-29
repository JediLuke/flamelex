defmodule Flamelex.GUI.RootScene do
  @moduledoc false
  use Scenic.Scene
  # use ScenicWidgets.ScenicEventsDefinitions  # Temporarily commented out due to compilation issues
  alias Flamelex.GUI.Layers.{Layer0, Layer01, NeoLayer02, Layer3, Layer4}
  import Scenic.Primitives
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
  # TODO document the layers system
  # root scene doesn't subscribe to changes, it just spins up 7 layer processes
  # these _do_ subscribe to changes, specifically, just the change in their layer ;)
  # Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

  # Scenic sends us lots of keypresses etc... easiest to just filter them
  # out right where they're detected (i.e. here), otherwise they clog up
  # things like keystroke history etc...

  # This trick to this module is the %Layer{} component which we wrap all
  # the graphs in. When a layer needs to change, it get's picked up by the
  # %Layer{} component, not the RootScene

  # cast is the real name of this (iot was above a transformation fn) function, we should use that, shoud blog about that...
  # what I mean by this is, that "cast" is transmute, it means 'change the type' or to 'change the form'


    # NOTE - due to the way Scenic works right now, it's not practical to pass in the RadixState from the highest level of the SUpervision tree
    # Maybe in the future this could change but for now just fetch this data when the Scenc boots... this is also kind of nice incase the GUI gets reset

    # I think I am coming up on a final decision & that is that fetching state during init
    # is absolutely the correct way to go as far as Elixir process management is concerned -
    # the GUI tree has no real concept of state management, it pushes actions
    # to another part of the system which process those changes, and it reacts to incoming
    # updates about state, but by itself Scenic is completely decoupled from all state management
    # now, as I go, there may come a point where this proves pretty inefficient, because
    # I can forsee myself having to have state in the state processing part of the app,
    # and the GUI, e.g. rendering a text buffer. However I'm just going to keep going this
    # way until I hit a wall because after all the trial & error, this is just the most ELixir-y
    # way to do it. Also I might just get some cool performance boosts e.g. Erlang doesnt deep copy
    # large strings, we can try and use ETS, etc...

  def init(scene, args, opts) do
    Logger.debug("#{__MODULE__} initializing...")

    rdx = Flamelex.Fluxus.RadixStore.get()

    graph = render_layers(scene.viewport, rdx)

    new_scene =
      scene
      |> assign(graph: graph)
      |> push_graph(graph)

    request_input(new_scene, [:viewport, :key])

    {:ok, new_scene}
  end

  def handle_input({:viewport, {:enter, _coords}}, context, scene) do
    # Logger.debug "#{__MODULE__} ignoring `:viewport_enter`..."
    {:noreply, scene}
  end

  def handle_input({:viewport, {:exit, _coords}}, context, scene) do
    # Logger.debug "#{__MODULE__} ignoring `:viewport_exit`..."
    {:noreply, scene}
  end

  def handle_input({:viewport, {:reshape, _size}}, context, scene) do
    Logger.debug("#{__MODULE__} ignoring `:viewport_reshape`...")
    {:noreply, scene}
  end

  # e.g. of new_dimensions: {1025, 818}
  # def handle_input(
  #       {:viewport, {:reshape, {new_width, new_height} = new_dimensions}},
  #       context,
  #       scene
  #     ) do
  #   # Logger.debug "#{__MODULE__} received :viewport :reshape, dim: #{inspect new_dimensions}"

  #   new_viewport = %{scene.viewport | size: new_dimensions}
  #   Flamelex.Fluxus.RadixStore.update_viewport(new_viewport)

  #   {:noreply, %{scene | viewport: new_viewport}}
  # end

  # Ignore key releases
  # def handle_input({:key, {key, @key_released, _opts}}, _context, scene) do
  #   # Logger.debug "#{__MODULE__} `key_released` for keypress: #{inspect key}"
  #   {:noreply, scene}
  # end

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
      Logger.warn(
        "#{__MODULE__} the key: #{inspect(key)} is being held, however `key_pressed` not valid"
      )

      {:noreply, scene}
    end
  end

  def handle_input({:cursor_button, _} = input, context, scene) do
    # Let mouse clicks be handled by the normal Scenic component tree first
    # If no component handles it, then it will bubble back up here
    {:noreply, scene}
  end

  def handle_input(input, context, scene) do
    # forward user input to Fluxus.Radix where it shall be processed against the current state to find the correct action
    Flamelex.Fluxus.user_input(input)
    {:noreply, scene}
  end

  # def handle_cast(:re_render, scene) do
  #   IO.puts("Re-rendering the root scene...")

  #   rdx = Flamelex.Fluxus.RadixStore.get()
  #   {:ok, graph} = render_layers(scene.viewport, rdx)

  #   new_scene =
  #     scene
  #     |> assign(graph: graph)
  #     |> push_graph(graph)

  #   {:noreply, new_scene}
  # end

  def render_layers(%Scenic.ViewPort{} = viewport, radix_state) do
    full_window = Widgex.Frame.new(viewport)

    # the app_frame is the frame of the app, minus the menubar
    app_frame = calc_app_frame(full_window, radix_state)

    # I'm experimenting with the idea of each layer fetching their own state from RadixState during init...
    # this way if layers reboots it fetches fresh state, and it feels like it would be more efficient rather
    # than passing it in from the top?

    Scenic.Graph.build()
    # Renseijin
    |> Layer0.add_to_graph(%{frame: app_frame})
    # the active apps layer
    |> Layer01.add_to_graph(%{frame: app_frame})
    # Menubar
    |> NeoLayer02.add_to_graph(%{frame: full_window})
    # popups & modals
    |> Layer3.add_to_graph(%{frame: app_frame})
    # Kommander
    |> Layer4.add_to_graph(%{frame: full_window})
  end

  def calc_app_frame(full_window_frame, %{layers: %{two: %{menubar: %{height: menubar_h}}}}) do
    [_menubar_frame, app_frame] = Widgex.Frame.v_split(full_window_frame, px: menubar_h)
    app_frame
  end

end

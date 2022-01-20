defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  # use Flamelex.GUI.ComponentBehaviour
  use Scenic.Component
  use Flamelex.ProjectAliases
  require Logger
  alias Flamelex.GUI.Component.MenuBar.Utils

  #TODO deprecate these, but also come up eith a better name!!
  @left_margin 15
  @tab_width 190

  def height, do: 40
  def menu_item(:left_margin), do: 15
  def menu_item_width, do: 190

  @skip_log false # this flag toggles logging of Errors which happen inside Wormhole - useful for debugging, but can be quite noisy (they are logged at level: :warn)

  #TODO all of this is hacks... we need to move rego_tag into the behaviour, and this needs to be a behaviour
  # def rego_tag(%{ref: %BufRef{ref: ref}}) do
  #   rego_tag(ref)
  # end
  # def rego_tag(%{ref: aa}) when is_atom(aa) do
  #   rego_tag(aa)
  # end
  def rego_tag(x), do: {:gui_component, :menu_bar}

  # def validate(%{
  #   ref: _ref,                  # Each component needs a ref. This will be used for addressing (sending the component messages)
  #   frame: %Frame{} = _f,       # Flamelex GUI components all have a defined %Frame{}
  #   state: _x} = data)          # `state` is the holder for whatever data it is which defines the internal state of the component (usually a map)
  def validate(data)
do
  {:ok, data}
end

  @doc """
  This function returns a map which describes all the menu items.
  """
  # def custom_menu_map
  #TODO this should be a list, not a map, then the order is enforced
  def menu_buttons_mapping do
    # top-level buttons

    default_map = %{
      "Flamelex" => %{
        "temet nosce" => {Flamelex, :temet_nosce, []},
        "show cmder" => {Flamelex.API.CommandBuffer, :show, []}
      },
      "Memex" => %{
        "open" => {Flamelex.API.MemexWrap, :open, []},
        "random quote" => {Flamelex.Memex, :random_quote, []},
        "journal" => {Flamelex.MemexWrap.Journal, :now, []}
      },
      "GUI" => %{}, #TODO auto-generate it from the GUI file
      "Buffer" => %{
        "open README" => {Flamelex.API.Buffer, :open!, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
        # "close" => {Flamelex.API.Buffer, :close, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
        "close" => fn -> Buffer.active_buffer() |> Buffer.close() end
      },
      "DevTools" => %{},
      "Help" => %{
        "Getting Started" => nil,
        "About" => nil
      },
    }

    
    case Memex.Env.ExecutiveManager |> Process.whereis() do
      pid when is_pid(pid) ->
        {:ok, name} = GenServer.call(Memex.Env.ExecutiveManager, :who_am_i?)
        case GenServer.call(Memex.Env.ExecutiveManager, :fetch_custom_menu) do
          {:ok, custom_menu} ->
            default_map |> Map.merge(Map.new([{name, custom_menu}]))
          {:error, _reason} ->
            default_map
        end
      _otherwise ->
        default_map
    end
  end

  def menubar_schematic do
    # Can be either:
    #   a) just a string (maybe a button, no drop-down)
    #   b) a tuple with a label & the drop-down

    [
      {"Flamelex", [
        {"temet nosce", {Flamelex, :temet_nosce, []}},
        {"show cmder", {Flamelex.API.CommandBuffer, :show, []}}
      ]},
      {"Memex", [
        # {"temet nosce", {Flamelex, :temet_nosce, []}}
        # {"show cmder", {Flamelex.API.CommandBuffer, :show, []}
      ]},
    ]

    ++ memex_custom_modulez() ++ [
      "Help"
    ]
  end

  def memex_custom_modulez do
    {"My Customz", [
      {Memelex.Journal, :now, []}
    ]}
  end


  def init(scene, params, opts) do
    Process.register(self(), __MODULE__)

    #NOTE: The `state` of this Component is used to track where we have
    #      hovered the mouse to.

    new_scene =
      scene
      |> assign(frame: params.frame)
      |> assign(menu_tree: menu_buttons_mapping())
      |> assign(state: :not_hovering_over_menubar)
      |> render_push_graph()

    #NOTE: Ok so, if we capture input here, then it doesn't show up in
    #      the Transmujen...
    #
    #TODO tomorrow - move this capture input into the GUI.Controller, and
    #                then (for now) just broadcast it to both components which need it
    #

    request_input(new_scene, [:cursor_pos, :cursor_button, :key])

    {:ok, new_scene}
  end


  @impl Scenic.Scene
  def handle_input(input, _context, scene) do
    #Logger.debug "#{__MODULE__} received input: #{inspect input}"
    {:noreply, _new_scene} = process_input(scene, input)

    #NOTE: I originally thought about putting this functionality inside
    #      Utils, but this is a good case study where we shouldn't do that.
    #      The reason is because, Utils is supposed to only contain
    #      pure-functions, and push_graph() has side-effects. For that
    #      reason,  I think it *has* to be a defp within this module.
    # case Wormhole.capture(Utils, :handle_input, [scene, input], skip_log: @skip_log) do
    #   {:ok, %{assigns: %{state: ^init_state}}} ->
    #       # no change in state, nothing to re-draw
    #       #Logger.debug "no change in state... (current state: #{inspect init_state})"
    #       {:noreply, scene}
    #   {:ok, %Scenic.Scene{assigns: %{state: new_state}} = new_scene} ->
    #       #Logger.debug "changed state! init_state: #{inspect init_state}, new_state: #{inspect new_state}"
    #       new_scene |> render_push_graph()
    #       {:noreply, new_scene}
    #   {:error, reason} ->
    #       Logger.error "#{__MODULE__} unable to handle some input! #{inspect reason}"
    #       {:noreply, scene} # make no changes
    # end


    # # in dev-mode, in this process (so we get good error logs),
    # # we always re-render due to every piece of user input
    #NOTE: dev-mode
    #      To get better error logs, I sometimes use this, but NEVER in
    #      PROD!! It crashes the _Component_
    # new_scene = %Scenic.Scene{} = Utils.handle_input(scene, input) #NOTE: handle_input/1 *must* return a %Scene{}, this is just a primitive assertion of this fact
    # new_scene |> render_push_graph()
    # {:noreply, new_scene}
  end

  @doc """
  Here we're just calling a handler function (where are all pure-functions)
  to determinne the state-change, if any, as a result of the input being
  handled. If there is, we call render_push_graph()

  As an extra note, I originally thought about putting this functionality
  inside Utils, but this is a good case study where we shouldn't do that.
  The reason is because, Utils is supposed to only contain pure-functions,
  and push_graph() has side-effects. For that reason,  I think it *has*
  to be a def/defp within this module.
  """
  #TODO this is what we want inside EACH GUI.component - handling input is wrapped in Wormhole
  def process_input(%{assigns: %{state: init_state}} = scene, input) do
    case Wormhole.capture(Utils, :handle_input, [scene, input], skip_log: @skip_log) do #TODO each component should automatically also have a reducer to handle input
      {:ok, %Scenic.Scene{assigns: %{state: ^init_state}}} ->
          # no change in state, nothing to re-draw
          #Logger.debug "no change in state... (current state: #{inspect init_state})"
          {:noreply, scene}
      {:ok, %Scenic.Scene{assigns: %{state: new_state}} = new_scene} ->
          #TODO revert to debug after Scenic meetup
          Logger.info "#{__MODULE__} changed state! init_state: #{inspect init_state}, new_state: #{inspect new_state}"
          new_scene |> render_push_graph()
          {:noreply, new_scene}
      {:error, reason} ->
          Logger.error "#{__MODULE__} unable to handle some input! #{inspect reason}"
          {:noreply, scene} # make no changes
    end
  end

  ## PRO-TIP: *Don't* track your graphs in a component (maybe?).
  #     There should be no need - graphs are throways.
  #     Generated by a pure function, from the internal
  #     state of the Scene.
  #
  #     addendum: This seemed like a nice idea, in practice though we
  #     do need to keep track of the graph, even if only for this like,
  #     if we want to swap to another screen, if we have the old graph
  #     we can just swap back
  def render_push_graph(%{assigns: %{state: init_state}} = scene) do
    #NOTE: On the flip side, we are (potentially? Maybe Scenic optimizes?)
    #      re-drawing the entire graph for every mouse-movement...
    case Wormhole.capture(Utils, :render, [scene], skip_log: @skip_log) do
      #TODO chek for state changes here
      {:ok, new_scene} ->
        new_scene |> push_graph(new_scene.assigns.graph)
      {:error, reason} ->
        Logger.error "#{__MODULE__} unable to render Scene! #{inspect reason}"
        scene # make no changes
    end

    #NOTE: dev-mode
    #      To get better error logs, I sometimes use this, but NEVER in
    #      PROD!! It crashes the _Component_
    # new_scene = %Scenic.Scene{} = Utils.render(scene) #NOTE: render/1 *must* return a %Scene{}, this is just a primitive assertion of this fact
    # new_scene |> push_graph(new_scene.assigns.graph)
  end

end

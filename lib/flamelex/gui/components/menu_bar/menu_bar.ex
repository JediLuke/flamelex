defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.Component.MenuBar.Utils

  #TODO deprecate these, but also come up eith a better name!!
  @left_margin 15
  @tab_width 190

  def height, do: 40
  def menu_item(:left_margin), do: 15
  def menu_item_width, do: 190


  #TODO all of this is hacks... we need to move rego_tag into the behaviour, and this needs to be a behaviour
  # def rego_tag(%{ref: %BufRef{ref: ref}}) do
  #   rego_tag(ref)
  # end
  # def rego_tag(%{ref: aa}) when is_atom(aa) do
  #   rego_tag(aa)
  # end
  def rego_tag(x), do: {:gui_component, :menu_bar}


  @doc """
  This function returns a map which describes all the menu items.
  """
  def menu_buttons_mapping do
    # top-level buttons
    %{
      "Flamelex" => %{
        "temet nosce" => {Flamelex, :temet_nosce, []},
        "show cmder" => {Flamelex.API.CommandBuffer, :show, []}
      },
      "Memex" => %{
        "random quote" => {Flamelex.Memex, :random_quote, []},
        "journal" => {Flamelex.Memex.Journal, :now, []}
      },
      "GUI" => %{}, #TODO auto-generate it from the GUI file
      "Buffer" => %{
        "open README" => {Flamelex.Buffer, :open!, []},
        "close" => {Flamelex.Buffer, :close, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
      },
      "DevTools" => %{},
      "Help" => %{},
    }
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

    capture_input(new_scene, [:cursor_pos])
    # capture_input(new_scene, [:cursor_pos, :cursor_button])

    {:ok, new_scene}
  end


  @skip_log false
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
  def process_input(%{assigns: %{state: init_state}} = scene, input) do
    case Wormhole.capture(Utils, :handle_input, [scene, input], skip_log: @skip_log) do
      {:ok, %{assigns: %{state: ^init_state}}} ->
          # no change in state, nothing to re-draw
          #Logger.debug "no change in state... (current state: #{inspect init_state})"
          {:noreply, scene}
      {:ok, %Scenic.Scene{assigns: %{state: new_state}} = new_scene} ->
          #Logger.debug "changed state! init_state: #{inspect init_state}, new_state: #{inspect new_state}"
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
  def render_push_graph(scene) do

    # #NOTE: On the flip side, we are (potentially? Maybe Scenic optimizes?)
    # #      re-drawing the entire graph for every mouse-movement...
    # case Wormhole.capture(Utils, :render, [scene], skip_log: true) do
    #   {:ok, new_scene} ->
    #     new_scene |> push_graph(new_scene.assigns.graph)
    #   {:error, reason} ->
    #     Logger.error "#{__MODULE__} unable to render Scene! #{inspect reason}"
    #     scene # make no changes
    # end

    #NOTE: dev-mode
    #      To get better error logs, I sometimes use this, but NEVER in
    #      PROD!! It crashes the _Component_
    new_scene = %Scenic.Scene{} = Utils.render(scene) #NOTE: render/1 *must* return a %Scene{}, this is just a primitive assertion of this fact
    new_scene |> push_graph(new_scene.assigns.graph)
  end

end

defmodule Flamelex.GUI.Component.SampleComponent do
  @moduledoc """
  This module is just an example. Copy & modify it.

  # Adding a new component to the GUI

  To understand how to add a new component, we need to look in to how they
  are rendered. We use Scenic to draw all our graphics. At the very base
  layer, our Graphics are nothing more than a single %Scenic.Graph{} struct
  help in the the `Flamelex.GUI.RootScene` process.

  At the very bottom of the abstraction, we have a %Scenic.Graph{}. To
  update this Graph, we need to modify it and push it - this involves
  sending an update to the `RootScene` process.

  The way Scenic works, is that although in some way a component is just
  another entry into the Scenic Graph, a Scenic component is special in
  that it has it's own process backing it, and what's in the Scenic.Graph
  held in the RootScene is just a reference to that other process, which
  will in turn contain a Scenic.Graph, representing the component.

  To alert components of changes, components need to register themselves
  to the `:gui_update_bus` and any GUI update events will be sent to all
  registered GUI components - it is the responsibility of each component
  to either ignore or react ;) to updates as they come in.
  """
  use Flamelex.GUI.ComponentBehaviour

  @impl Flamelex.GUI.ComponentBehaviour
  def custom_init_logic(_frame, _params) do # TODO this is kind of like `mount`
    :none
  end

  @doc """
  render/1 accepts a %Frame{}, and returns a %Scenic.Graph{} which can be
  drawn to the screen.

  The main idea of this function is to use the data you've passed in (all
  the GUI related state ought to be inside the %Frame{}...) to render the
  graph.

  In this simple case, we will just draw a border around the Frame, but
  obviously this can get quite detailed.
  """
  @impl Flamelex.GUI.ComponentBehaviour
  def render(%Frame{} = frame, _params) do

    # Draw.blank_graph()
    Scenic.Graph.build()
    # |> Draw.background(frame, :green)
    |> Draw.test_pattern()
    |> Draw.border(frame)
  end

  @doc """
  Here in handle_action, you put all your callbacks for when you want the
  component to *react* to things <cough>

  The first param looks like this:

    {graph, state}

  This is how you would send a GUI component an action:

  SampleComponent.action({:a_sample_action, map_of_params})

  Actions can be anything - an atom, a tuple, etc. - but the component
  *must* implement a handle_action/2 callback for it, or else it will
  raise an error.

  Actions can return one of these values:

    :ignore_action


  """
  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_graph, _state}, action) do
    :ignore_action
  end

  @doc """
  This callback is called whenever the component received input.
  """
  @impl Scenic.Scene
  def handle_input(event, _context, state) do
    {:noreply, state}
  end

  @doc """
  When placed at the bottom of the module, this function would serve as
  a "catch-all", by pattern-matching on all actions that weren't matched
  in a `handle_action/2` callback defined above.
  """
  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_action({graph, _state}, action) do
  #   Logger.debug "#{__MODULE__} with id: #{inspect state.id} received unrecognised action: #{inspect action}"
  #   :ignore_action
  # end
end

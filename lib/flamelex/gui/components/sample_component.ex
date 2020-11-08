defmodule Flamelex.API.GUI.Component.SampleComponent do
  @moduledoc """
  This module is just an example. Copy & modify it.
  """
  use Flamelex.API.GUI.ComponentBehaviour


  @doc """
  render/1 accepts a %Frame{}, and returns a %Scenic.Graph{} which can be
  drawn to the screen.

  The main idea of this function is to use the data you've passed in (all
  the GUI related state ought to be inside the %Frame{}...) to render the
  graph.

  In this simple case, we will just draw a border around the Frame, but
  obviously this can get quite detailed.
  """
  @impl Flamelex.API.GUI.ComponentBehaviour
  def render(%Frame{} = frame, _params) do

    Draw.blank_graph()
    # |> Draw.background(frame, :green)
    |> Draw.border(frame)
  end

  @doc """
  Here in handle_action, you put all your callbacks for when you want the
  component to *react* to things <cough>

  The first param looks like this:

    {graph, state}

  This is the current... (#TODO finish this)
  """
  @impl Flamelex.API.GUI.ComponentBehaviour
  def handle_action({graph, _state}, {:sample_action, _some_params}) do
    :ignore_action
  end

  @doc """
  This callback is called whenever the component received input.
  """
  @impl Scenic.Scene
  def handle_input(event, _context, state) do
    Logger.debug "#{__MODULE__} received event: #{inspect event}"
    {:noreply, state}
  end

  @doc """
  When placed at the bottom of the module, this function would serve as
  a "catch-all", by pattern-matching on all actions that weren't matched
  in a `handle_action/2` callback defined above.
  """
  # @impl Flamelex.API.GUI.ComponentBehaviour
  # def handle_action({graph, _state}, action) do
  #   Logger.debug "#{__MODULE__} with id: #{inspect state.id} received unrecognised action: #{inspect action}"
  #   :ignore_action
  # end
end

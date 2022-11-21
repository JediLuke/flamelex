defmodule Flamelex.Fluxus.RadixStore do
  @moduledoc """
  This module just stores the actual state itself - modifications are
  made elsewhere.

  https://www.bounga.org/elixir/2020/02/29/genserver-supervision-tree-and-state-recovery-after-crash/

  The GUI.Component and the Buffer.Component have a shared state, via an
  Agent process. They receive an action, they go fetch the state, they
  can lock it if needed (call), and they can process it. If the state changes,
  then act of changing it can publish a msg to other listeners (i.e. the
  GUI.Component) who will have to re-render their shit.

  Although I did try it, I decided not to go with using the event-bus for
  updating the GUI due to a state change. The event-bus serves it's purpose
  by funneling all action through one choke-point, and keeps track of
  them etc, but just pushing updates to the GUI is simpler when done via
  a PubSub (no need to acknowledge events as complete), and easier to
  implement, since the EventBus lib we're using receives events in a
  separate process to the one where we actually declared the function.
  We could forward the state updates on to each ScenicComponent, but then
  we start to have problems of how to handle addressing... the exact problem
  that PubSub is a perfect solution for.
  """
  use Agent
  require Logger

  #TODO make this a GenServer & do all edits in the context of the GenServer

  def start_link(_params) do
    radix_state = Flamelex.Fluxus.Structs.RadixState.initialize()
    Agent.start_link(fn -> radix_state end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  #NOTE: Here we update, but don't broadcast the changes. For example,
  #      adding user-input to the input history, doesn't need to be broadcast.
  def put(new_state) do
    #Logger.debug("#{__MODULE__} updating state...")
    Agent.update(__MODULE__, fn _old -> new_state end)
  end

  def put_viewport(%Scenic.ViewPort{} = new_vp) do
    Agent.update(__MODULE__, fn radix_state ->
      radix_state |> put_in([:gui, :viewport], new_vp)
    end)
  end

  #NOTE: When `Flamelex.GUI.RootScene` boots, it calls this function.
  #      We don't want to broadcast these changes out.
  def put_root_graph(new_graph) do
    Agent.update(__MODULE__, fn radix_state ->
      radix_state
      |> put_in([:root, :graph], new_graph)
    end)
  end

  # update/1 also broadcasts changes to the rest of the app
  def update(new_state) do
    #Logger.debug("#{__MODULE__} updating state & broadcasting new_state...")
    #Logger.debug("#{__MODULE__} updating state & broadcasting new_state: #{inspect(new_state)}")

    Flamelex.Utils.PubSub.broadcast(
        topic: :radix_state_change,
        msg: {:radix_state_change, new_state})

    Agent.update(__MODULE__, fn _old -> new_state end)
  end

  def update_viewport(%Scenic.ViewPort{} = new_vp) do
    Agent.update(__MODULE__, fn radix_state ->
      
      new_radix_state =
        radix_state |> put_in([:gui, :viewport], new_vp)

      Flamelex.Utils.PubSub.broadcast(
        topic: :radix_state_change,
        msg: {:radix_state_change, new_radix_state})

      new_radix_state
    end)
  end
end

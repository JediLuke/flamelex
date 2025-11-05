defmodule Flamelex.GUI.Layers.NeoLayer02 do
  use Scenic.Component
  alias Flamelex.GUI.Layers.Layer2
  require Logger

  # How is layer 2 different? Layer2 relies on rdx state to compute it's own state (it needs to know what buffers etc exist)
  # which became a circular reference issue, how can I put layer2 state in rdx when it needs rdx to be calculated...
  # so layer2 is the only one which doesn't try to put it's state back into rdx state, it just computes it from
  # rdx state and keeps track of it's state from here on down. This may be an issue in the future if for some reason
  # I need to know the layer 2 state to make some kind of reducer decision or whatever... but it works for now

  # possible in the future, I can put layer 2 state back up into the radix state - it would mean I need to call Layer2
  # mutators on various operations like adding a new buffer etc to update layer 2 and re-compute the menu map - it's
  # diable but for now it's just not solving any actual problem I have, this works

  def validate(%{frame: %Widgex.Frame{} = frame} = data) do
    {:ok, frame}
  end

  def init(
    %Scenic.Scene{} = scene,
    %Widgex.Frame{} = frame,
    _opts
  ) do

    rdx = Flamelex.Fluxus.RadixStore.fetch()
IO.inspect(rdx.memex, label: "L2 rdx mmx")
IO.inspect(rdx.layers.two |> Map.keys(), label: "rdx $$/?")
    state = Layer2.State.new(rdx)
	|> IO.inspect(label: "L2 STATE")
    graph = Layer2.Renderizer.render(frame, state)

    new_scene =
      scene
      |> assign(frame: frame)
      |> assign(state: state)
      |> assign(graph: graph)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, new_scene}
  end

  def handle_info(
    {:radix_state_change, rdx},
    scene
  ) do

    l2_state = Layer2.State.new(rdx)

    if l2_state == scene.assigns.state do
      # state didn't change, do nothing
      IO.puts "MENUBAR STATE SAME"
      {:noreply, scene}
    else
      new_graph = Layer2.Renderizer.render(scene.assigns.frame, l2_state)

      new_scene =
        scene
        |> assign(state: l2_state)
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

      {:noreply, new_scene}
    end
  end
end

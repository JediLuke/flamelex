defmodule Flamelex.GUI.Component.Layer do
    use Scenic.Component
    require Logger
    
    def validate(%{id: x, graph: _g} = data) do
        {:ok, data}
    end

    def init(scene, args, opts) do

        init_scene = scene
        #TODO wrap in a group
        |> assign(id: args.id)
        |> assign(graph: args.graph)
        |> push_graph(args.graph)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        {:ok, init_scene}
    end

  # def handle_info({:radix_state_change,
  #       %{root: %{layers: %{two: new_second_layer}}}},
  #       %{assigns: %{layer_2: current_layer_2}} = scene)
  # when new_second_layer != current_layer_2 do
  def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do

    this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
    [{^this_layer, radix_layer_graph}] =
        layer_list |> Enum.filter(fn {layer, graph} -> layer == scene.assigns.id end)

    if scene.assigns.graph != radix_layer_graph do
        Logger.debug "#{__MODULE__} Layer_ #{inspect scene.assigns.id} changed, re-drawing the RootScene..."
        
        new_scene = scene
        |> assign(graph: radix_layer_graph)
        |> push_graph(radix_layer_graph)

        {:noreply, new_scene}
    else
        Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
        {:noreply, scene}
    end
  end

  def handle_info({:radix_state_change, _new_radix_state}, scene) do
    Logger.debug "#{__MODULE__} ignoring a RadixState change..."
    {:noreply, scene}
  end

end
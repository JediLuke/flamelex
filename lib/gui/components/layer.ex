defmodule Flamelex.GUI.Component.Layer do
   use Scenic.Component
   require Logger
   
   @layers [
      Flamelex.GUI.Layers.LayerZero,
      Flamelex.GUI.Layers.LayerOne,
      Flamelex.GUI.Layers.LayerTwo,
      Flamelex.GUI.Layers.LayerThree
   ]

   # #TODO accept a function, which is the render function - takes in a radix_state, re-computes entire layer, this is how we know if layers needs to be updated!!
   # def validate(%{graph: %Scenic.Graph{} = _g, render_fn: render_fn} = data) when is_function(render_fn) do
   #    {:ok, data}
   # end

   def validate(%{layer_module: layer, radix_state: radix_state} = data) when layer in @layers do
      {:ok, data}
   end

   #TODO handle the state & calc_state_fn not being mandatory args...

   def init(scene, %{layer_module: layer, radix_state: radix_state} = args, opts) do
      Logger.debug "Initializing layer #{opts[:id]}..."

      init_state = layer.calc_state(radix_state)
      init_graph = layer.render(init_state, radix_state)

      init_scene = scene
      # |> assign(id: opts[:id] || raise "invalid ID")
      |> assign(layer: layer)
      |> assign(graph: init_graph)
      |> assign(state: init_state)
      |> push_graph(init_graph)

      Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

      {:ok, init_scene}
   end

   # def init(scene, args, opts) do
   #    init_scene = scene
   #    |> assign(id: opts[:id] || raise "invalid ID")
   #    |> assign(render_fn: args.render_fn)
   #    |> assign(calc_state_fn: args[:calc_state_fn] || nil)
   #    |> assign(graph: args.graph)
   #    |> assign(state: args[:state] || nil)
   #    |> push_graph(args.graph)

   #    Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

   #    {:ok, init_scene}
   # end

   #NOTE that this is better because it uses the "layer state" to figure out if it needs to change. Layer state doesn't need to change *all* the time e.g. if we input a single character... that can be handled by the Editor component
   def handle_info(
      {:radix_state_change, new_radix_state},
      %{assigns: %{state: old_layer_state, layer: layer}} = scene
   ) do
      new_layer_state = layer.calc_state(new_radix_state)

      if new_layer_state != old_layer_state do
         new_graph = layer.render(new_layer_state, new_radix_state)

         new_scene =
            scene
            |> assign(state: new_layer_state)
            |> assign(graph: new_graph)
            |> push_graph(new_graph)

         {:noreply, new_scene}
      else
         {:noreply, scene}
      end
   end

   # def handle_info({:radix_state_change, %{root: %{layers: layer_list}}}, scene) do
   # def handle_info({:radix_state_change, new_radix_state}, scene) do

   #    dbg()
   #    # #ONE IDEA - instead of triggering by changings in the layer list, re-compute the graph for this layer and change if it's it's changed...
   #    recomputed_layer_graph = scene.assigns.render_fn.(new_radix_state)

   #    # this_layer = scene.assigns.id #REMINDER: this will be an atom, like `:one`
   #    # [{^this_layer, this_layer_graph}] =
   #    #    layer_list |> Enum.filter(fn {layer, _graph} -> layer == scene.assigns.id end)

   #    if scene.assigns.graph != recomputed_layer_graph do
   #       IO.puts "!!!LAYER CHANGE!!!"
   #       Logger.debug "#{__MODULE__} Layer: #{inspect scene.assigns.id} changed, re-drawing the RootScene..."
         
   #       new_scene = scene
   #       |> assign(graph: recomputed_layer_graph)
   #       |> push_graph(recomputed_layer_graph)

   #       {:noreply, new_scene}
   #    else
   #       #Logger.debug "Layer #{inspect scene.assigns.id}, ignoring.."
   #       {:noreply, scene}
   #    end
   # end

  def handle_info({:radix_state_change, _new_radix_state}, scene) do
    #Logger.debug "#{__MODULE__} ignoring a RadixState change..."
    {:noreply, scene}
  end

end
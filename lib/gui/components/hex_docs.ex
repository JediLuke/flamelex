defmodule Flamelex.GUI.Components.HexDocs do
    use Scenic.Component
    alias ScenicWidgets.Core.Structs.Frame
    require Logger
 
    @elixir_location "/Users/luke/.asdf/installs/elixir/1.14.0"
  
    def validate(%{frame: %Frame{} = _f, state: _state} = data) do
       #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
       {:ok, data}
    end
 
    def init(scene, args, opts) do
 
       init_graph =
          render(args.frame, args.state)
 
       init_scene = scene
          |> assign(state: args.state)
          |> assign(frame: args.frame)
          |> assign(graph: init_graph)
          |> push_graph(init_graph)
 
       Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
 
       {:ok, init_scene}
    end
 
    def handle_info({:radix_state_change, _new_radix_state}, %{assigns: %{state: _current_state}} = scene) do
       # ignoring a RadixState update...
       {:noreply, scene}
    end
 
    def render(frame, state) do
       Scenic.Graph.build()
       |> Scenic.Primitives.group(fn graph ->
          graph
          # |> TODO put Graph drawing here...
          |> Scenic.Primitives.rect({100, 100}, fill: :red, translate: {250, 250})
       end, [
          id: __MODULE__
       ])
    end
 
 end
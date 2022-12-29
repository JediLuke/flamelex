defmodule Flamelex.GUI.Component.FileTree do
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger

 
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

      Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

      {:ok, init_scene}
   end

   def handle_info({:radix_state_change, %{projects: %{open_proj: proj}}}, %{assigns: %{state: %{open_proj: proj}}} = scene) do
      # In this case ^proj matches, therefore no change and we can ignore this upate
      {:noreply, scene}
   end

   def handle_info({:radix_state_change, %{projects: %{open_proj: new_proj} = new_state}}, scene) do
      # project has changed, so we update everything

      side_nav_state = calc_side_nav_state(new_state)

      
      {:ok, [pid]} = Scenic.Scene.child(scene, :file_tree)
      GenServer.cast(pid, {:state_change, side_nav_state})

      {:noreply, scene |> assign(state: new_state)}
   end

   def render(%Frame{} = frame, state) do
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
         graph
         |> ScenicWidgets.SideNav.add_to_graph(%{
            frame: frame,
            state: calc_side_nav_state(state)
         }, id: :file_tree)
      end, [
         id: __MODULE__
      ])
   end
   
   def calc_side_nav_state(%{open_proj: nil}) do
      %{
         nav_tree: []
      }
   end

   def calc_side_nav_state(%{open_proj: proj_dir}) when is_bitstring(proj_dir) do
      %{
         nav_tree: construct_nav_tree(proj_dir)
      }
   end

   def construct_nav_tree(dir) do
      files = File.ls!(dir)
      files
   end

 end
defmodule Flamelex.GUI.Component.FileExplorer do
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger

 
   def validate(%{frame: %Frame{} = _f, state: _state} = data) do
      #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end

   def init(scene, args, opts) do

      #TODO consider pulling the initial state from RadixState so that
      # if it breaks, it automatically updates...

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
      if not File.dir?(proj_dir) do
         raise "The path: #{inspect proj_dir} is not a directory."
      end

      #TODO order the items here? Alphabetically? Put directorys first?
      top_lvl_tree_items = File.ls!(proj_dir)
      
      %{
         nav_tree: construct_nav_tree(top_lvl_tree_items, [])
      }
   end

   def construct_nav_tree([], result) do
      #TODO move directory's to the top??
      result # base case
   end

   def construct_nav_tree([item|rest], result) do
      if File.dir?(item) do
         sub_items = File.ls!(item)
         new_result = result ++ [%{
            item: {:node, item, construct_nav_tree(sub_items, [])}
         }]
         
         #TODO for each of the sub menu items, need to append the current directory

         construct_nav_tree(rest, new_result)
      else
         #TODO need to a) get the full filepath here somehow
         
         new_result = result ++ [%{
            item: {:leaf, item},
            func: fn -> Flamelex.API.Buffer.open(item) end
         }]

         construct_nav_tree(rest, new_result)
      end
   end

 end
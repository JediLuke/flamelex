defmodule Flamelex.GUI.Component.FileExplorer do
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger

 
   def validate(%{frame: %Frame{} = _f, state: _state} = data) do
      #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end

   def init(scene, args, opts) do

      #TODO consider pulling the initial state from RadixState
      # so that if it breaks, it automatically updates...

      init_nav_tree = open_project(args.state.open_proj)

      init_graph =
         render(args.frame, init_nav_tree)

      init_scene = scene
         |> assign(state: Map.merge(args.state, %{nav_tree: init_nav_tree}))
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

      side_nav_state = open_project(new_proj)
      
      {:ok, [pid]} = Scenic.Scene.child(scene, :file_tree)
      GenServer.cast(pid, {:state_change, side_nav_state})

      {:noreply, scene |> assign(state: new_state)}
   end

   def render(%Frame{} = frame, nav_tree) do
      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
         graph
         |> ScenicWidgets.SideNav.add_to_graph(%{
            frame: frame,
            state: nav_tree
         }, id: :file_tree)
      end, [
         id: __MODULE__
      ])
   end
   
   def open_project(_open_proj = nil) do
      []
   end

   def open_project(proj_dir) when is_bitstring(proj_dir) do
      if not File.dir?(proj_dir) do
         raise "The path: #{inspect proj_dir} is not a directory."
      end

      top_lvl_tree =
         with files_and_dirs <- File.ls!(proj_dir),
            {files, directories} <- split_files_and_directories(files_and_dirs),
            sorted_dirs <- sort_alphabetically(directories),
            directory_tuples <- construct_dir_tuples(proj_dir, sorted_dirs),
            sorted_files <- sort_alphabetically(files),
            file_tuples <- construct_file_tuples(proj_dir, sorted_files) do
               directory_tuples ++ file_tuples
            end

      construct_nav_tree(top_lvl_tree, [0], [])
   end

   def construct_nav_tree([], _final_index, result) do
      result # base case
   end

   def construct_nav_tree([{:closed_node, label}|rest], index, result) do
      new_index = increment_index(index)
      new_result = result ++ [{:closed_node, label, new_index}]
      construct_nav_tree(rest, new_index, new_result)
   end

   # def construct_nav_tree([{:open_node, dir}|rest], result) do
   #    #TODO get last piece of the path here
   #    label = "Luke"
   #    index = [1,2]
   #    sub_tree = []
   #    new_result = result ++ [{:open_node, label, index, sub_tree}]
   #    construct_nav_tree(rest, new_result)
   # end

   def construct_nav_tree([{:leaf, label, click_fn}|rest], index, result) do
      new_index = increment_index(index)
      new_result = result ++ [{:leaf, label, new_index, click_fn}]
      construct_nav_tree(rest, new_index, new_result)
   end

   def split_files_and_directories(files_and_dirs) do
      files_and_dirs
      #NOTE: We need the `not` here so `files` comes first, and `directories` is the second list
      |> Enum.split_with(fn x -> not File.dir?(x) end)
   end

   def sort_alphabetically(items) do
      Enum.sort(items, &(String.downcase(&1) <= String.downcase(&2)))
   end

   def construct_dir_tuples(root_dir, dirs) do
      dirs |> Enum.map(fn dir -> {:closed_node, dir} end)
   end

   def construct_file_tuples(root_dir, files) do
      files |> Enum.map(fn filename ->
         #TODO include proj_dir here so it works outside flamelex
         open_file_fn = fn -> Flamelex.API.Buffer.open(filename) end
         {:leaf, filename, open_file_fn}
      end)
   end

   def increment_index(index) do
      # increment the last item in the list
      [last_index|other_indexes] = Enum.reverse(index)
      Enum.reverse([last_index+1|other_indexes])
   end

end
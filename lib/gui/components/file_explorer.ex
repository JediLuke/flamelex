defmodule Flamelex.GUI.Component.FileExplorer do
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger

   # dont show these in the FileExplorer because they're too big & mostly useless
   @ignored_dirs [".git", "_build", "deps"]
   @ignored_files [".DS_Store"]
 
   def validate(%{frame: %Frame{} = _f, state: _state} = data) do
      #Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
      {:ok, data}
   end

   def init(scene, args, opts) do

      #TODO consider pulling the initial state from RadixState
      # so that if it breaks, it automatically updates...

      init_nav_tree =
         construct_tuple_tree(args.state.open_proj)
         |> count_offsets([0], [])

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
      side_nav_state =
         construct_tuple_tree(new_proj)
         |> count_offsets([0], [])
      
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

   # def construct_tuple_tree(dir) do
   #    # the scond argument to this function is a list of offsets.
   #    # When calling this on the top level directory, this needs
   #    # to be initialized to an empty list (as we don't have any
   #    # offsets yet), but this function gets called recursively
   #    # (when calculating the offsets of nested sub-directories)
   #    # so we need to be able to pass this in for those cases
   #    construct_tuple_tree(dir, [])
   # end
   
   # Sometimes this can get called with `nil`, e.g. if there's no open project
   def construct_tuple_tree(nil) do
      []
   end

   def construct_tuple_tree(root_dir) when is_bitstring(root_dir) do
      if not File.dir?(root_dir) do
         raise "The path: #{inspect root_dir} is not a directory."
      end

      files_and_dirs = File.ls!(root_dir) |> filter_ignored()
      {files, dirs} = split_files_and_directories(root_dir, files_and_dirs)
      
      sorted_dirs = sort_alphabetically(dirs)
      sorted_files = sort_alphabetically(files)
         
      dir_tuples = construct_dir_tuples(root_dir, sorted_dirs)
      file_tuples = construct_file_tuples(root_dir, sorted_files)
      
      dir_tuples ++ file_tuples # directories get put at the top
   end

   def filter_ignored(dirs) do
      Enum.filter(dirs, & not Enum.member?(@ignored_dirs ++ @ignored_files, &1))
   end

   def split_files_and_directories(root_dir, files_and_dirs) do
      files_and_dirs
      #NOTE: We need the `not` here so `files` comes first,
      #      and `directories` is the second list
      |> Enum.split_with(fn x -> not File.dir?(root_dir <> "/" <> x) end)
   end

   def sort_alphabetically(items) do
      Enum.sort(items, &(String.downcase(&1) <= String.downcase(&2)))
   end

   def construct_dir_tuples(root_dir, dirs) do
      # NOTE: here we recursively call `construct_tuple_tree`
      dirs |> Enum.map(fn dir ->
         sub_tree = construct_tuple_tree(root_dir <> "/" <> dir)
         {:closed_node, dir, sub_tree}
      end)
   end

   def construct_file_tuples(root_dir, files) do
      files |> Enum.map(fn filename ->
         open_file_fn = fn -> Flamelex.API.Buffer.open(root_dir <> "/" <> filename) end
         {:leaf, filename, open_file_fn}
      end)
   end

   def count_offsets([], _final_index, result) do
      result # base case
   end

   # start recursive algorithm with a new last-offset of `[0]` (because
   # we increment it as the first step, so it begins at 1 anyway) and
   # the final arg, the results, as an empty list
   def count_offsets([{:closed_node, label, sub_tree}|rest], index, result) do
      #NOTE: For nodes, we need to recursively count the indexes for the sub-tree aswell
      new_index = increment_index(index)
      new_sub_tree = count_offsets(sub_tree, new_index ++ [0], [])
      new_result = result ++ [{:closed_node, label, new_index, new_sub_tree}]
      count_offsets(rest, new_index, new_result)
   end

   # def count_offsets([{:open_node, dir}|rest], result) do
   #    sub_tree = []
   #    new_result = result ++ [{:open_node, label, index, sub_tree}]
   #    count_offsets(rest, new_result)
   # end

   def count_offsets([{:leaf, label, click_fn}|rest], index, result) do
      new_index = increment_index(index)
      new_result = result ++ [{:leaf, label, new_index, click_fn}]
      count_offsets(rest, new_index, new_result)
   end

   def increment_index(index) do
      # increment the last item in the list
      [last_index|other_indexes] = Enum.reverse(index)
      Enum.reverse([last_index+1|other_indexes])
   end

end
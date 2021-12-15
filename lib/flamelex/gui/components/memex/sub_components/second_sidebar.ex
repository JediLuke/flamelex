defmodule Flamelex.GUI.Component.Memex.SecondSideBar do
   use Flamelex.GUI.ComponentBehaviour
   alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar

   @search_box_offset 250  # how far down from the top we want the search box to render
   @search_box_height 40   # how large (in pixels) we want the search box to be

   def custom_init_logic(_scene, args) do
      args |> Map.merge(%{state: %{mode: :normal}})   
   end

   def render(graph, %{first_render?: true, frame: frame, state: %{mode: :normal}}) do
      full_frame = {w, h} = {frame.dimensions.width, frame.dimensions.height}
      graph
      |> Scenic.Primitives.rect(full_frame, fill: :purple)
      |> Sidebar.SearchBox.add_to_graph(%{
            id: :search_box,
            frame: Frame.new(pin: {0, @search_box_offset}, size: {w, @search_box_height}),
            mode: :inactive},
            id: :search_box)
      |> Sidebar.LowerPane.mount(%{
            ref: :lower_pane,
            frame: Frame.new(pin: {0, @search_box_offset+@search_box_height}, size: {w, h-@search_box_offset-@search_box_height}),
            state: %{mode: :normal}
      })
   end

   def handle_cast(:test, scene) do
      IO.puts "GOT IT"
      # ProcessRegistry.find!({:gui_component, Flamelex.GUI.Component.Memex.SecondSideBar, :second_sidebar})
      # {:ok, [nil: #PID<0.3407.0>]} = Scenic.Scene.children(scene)

      # Scenic.Scene.send_children(scene, {:parent_msg, :hi})

      # Scenic.Scene.put_child(scene, {:parent_msg, :hi})

      # case Scenic.Scene.children(scene) do
      #    {:ok, children} ->
      #       {:noreply, scene}
      #    {:error, :no_children} ->
      #       {:noreply, scene}
      # end
      {:noreply, scene}
   end

end
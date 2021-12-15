defmodule Flamelex.GUI.Component.Memex.SecondSideBar do
   use Flamelex.GUI.ComponentBehaviour


   def render(graph, %{frame: frame}) do
      full_frame = {frame.dimensions.width, frame.dimensions.height}
      graph
      |> Scenic.Primitives.rect(full_frame, fill: :green)
   end
end
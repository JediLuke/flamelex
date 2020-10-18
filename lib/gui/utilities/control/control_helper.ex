defmodule Flamelex.GUI.Utilities.ControlHelper do
  use Flamelex.ProjectAliases


  def default_gui(%{viewport: vp}) do
    Draw.blank_graph()
    |> draw_transmutation_circle(vp)
    # |> GUI.Component.CommandBuffer.draw(viewport: vp)
    # |> GUI.Component.CommandBuffer.draw(state)
    |> mount_menubar(vp)
  end


  def draw_transmutation_circle(graph, vp) do

    #NOTE: We need the Frame here, so here is where we need to calculate
    #      how to position the TransmutationCicle in the middle of the viewport
    center_point = Dimensions.find_center(vp)
    scale_factor = 600 # how big the square frame becomes

    top_left_x_for_centered_frame = center_point.x - scale_factor/2
    top_left_y_for_centered_frame = center_point.y - scale_factor/2

    graph
    |> GUI.Component.TransmutationCircle.mount(
          Frame.new(
            top_left: {top_left_x_for_centered_frame, top_left_y_for_centered_frame},
            size:     {scale_factor, scale_factor}))
  end


  defp mount_menubar(graph, vp) do
    graph
    |> GUI.Component.MenuBar.mount(
          Frame.new(
            #TODO
            # buffer: %ListBuffer{},
            top_left: {0, 0},
            size:     {vp.width, GUI.Component.MenuBar.height()}))
  end
end

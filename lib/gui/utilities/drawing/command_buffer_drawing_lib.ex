defmodule Flamelex.GUI.Utilities.Drawing.CommandBufferDrawingLib do
  use Flamelex.ProjectAliases

  def frame(%Dimensions{} = viewport, name \\ "CommandBuffer") do
    Frame.new(
      name:     name,
      top_left: {0, 0},
      size:     {viewport.width, GUI.Component.MenuBar.height()})
  end
end

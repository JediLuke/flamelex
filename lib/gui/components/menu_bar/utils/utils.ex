defmodule Flamelex.GUI.Components.MenuBar.Utils do
  @moduledoc """
  Utility functions for the MenuBar component.
  """

  @doc """
  Checks if a coordinate is inside the given bounds.
  
  ## Parameters
    - coords: {x, y} tuple representing the coordinate to check
    - bounds: {left, top, right, bottom} tuple representing the bounds
    
  ## Returns
    - true if the coordinate is inside the bounds, false otherwise
  """
  def inside?({x, y}, {left, top, right, bottom}) do
    x >= left and y >= top and x <= right and y <= bottom
  end
end
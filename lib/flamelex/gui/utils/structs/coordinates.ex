defmodule Flamelex.API.GUI.Structs.Coordinates do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Flamelex.ProjectAliases

  defstruct [x: 0, y: 0]

  #TODO we ought to be validating inputs better here, checking for floats/ints,
  # and making sure they are positive


  def new(x: x, y: y) do
    %__MODULE__{
      x: x,
      y: y
    }
  end

  #TODO in future deprecate this, we prefer the above styling
  def new({x, y}) do
    %__MODULE__{
      x: x,
      y: y
    }
  end

  def modify(%__MODULE__{} = struct, x: new_x, y: new_y) do
    %{struct|x: new_x, y: new_y}
  end
end

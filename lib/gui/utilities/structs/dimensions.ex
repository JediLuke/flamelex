defmodule GUI.Structs.Dimensions do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Flamelex.CommonDeclarations

  defstruct [width: 0, height: 0]

  #TODO right now this works in pixels, we ought to consider supporting lines/columns

  def new({width, height}) when is_positive_integer(width) and is_positive_integer(height) do
    %__MODULE__{
      width: width,
      height: height
    }
  end

  #TODO right now this is needed for handling floats...
  def new({width, height}) do
    %__MODULE__{
      width: width,
      height: height
    }
  end

  def new(%{width: width, height: height}) do
    %__MODULE__{
      width: width,
      height: height
    }
  end

  def modify(%__MODULE__{} = struct, width: new_w, height: new_h) do
    %{struct|width: new_w, height: new_h}
  end
end

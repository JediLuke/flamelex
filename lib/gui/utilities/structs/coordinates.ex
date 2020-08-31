defmodule GUI.Structs.Coordinates do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Franklin.Misc.CustomGuards

  defstruct [x: 0, y: 0]

  # def new(%__MODULE__{} = struct) do #TODO just return same struct?
  #   struct
  # end

  def new({x, y}) when is_positive_integer(x) and is_positive_integer(y) do
    %__MODULE__{
      x: x,
      y: y
    }
  end

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

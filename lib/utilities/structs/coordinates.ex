defmodule GUI.Structs.Coordinates do
  @moduledoc """
  Struct which holds 2d points.
  """
  defstruct [x: 0, y: 0]
  defguard is_positive_integer(x) when is_integer(x) and x >= 0

  def initialize({x, y}) when is_positive_integer(x) and is_positive_integer(y) do
    %__MODULE__{
      x: x,
      y: y
    }
  end
end

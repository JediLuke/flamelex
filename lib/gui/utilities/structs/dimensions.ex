defmodule GUI.Structs.Dimensions do
  @moduledoc """
  Struct which holds 2d points.
  """
  defstruct [width: 0, height: 0]
  defguard is_positive_integer(x) when is_integer(x) and x >= 0

  def initialize({width, height}) when is_positive_integer(width) and is_positive_integer(height) do
    %__MODULE__{
      width: width,
      height: height
    }
  end
end

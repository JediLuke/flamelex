defmodule Flamelex.GUI.Structs.Dimensions do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Flamelex.{ProjectAliases, CustomGuards}


  #TODO right now this works in pixels, we ought to consider supporting lines/columns
  defstruct [
    width:  0,
    height: 0
  ]


  def new(:viewport_size) do
    %{size: dimensions} = Flamelex.GUI.Initialize.viewport_config()
    new(dimensions)
  end

  def new(width: width, height: height) do
    %__MODULE__{width: width, height: height}
  end

  #TODO deprecate these...
  def new({width, height}) when is_positive_integer(width) and is_positive_integer(height) do
    %__MODULE__{width: width, height: height}
  end

  #TODO right now this is needed for handling floats...
  def new({width, height}) do
    %__MODULE__{width: width, height: height}
  end

  def new(%{width: width, height: height}) do
    %__MODULE__{width: width, height: height}
  end

  def modify(%__MODULE__{} = struct, width: new_wid, height: new_hgt) do
    %{struct|width: new_wid, height: new_hgt}
  end

  def find_center(%__MODULE__{} = dimensions) do
    Coordinates.new(
        x: dimensions.width  / 2,
        y: dimensions.height / 2)
  end
end

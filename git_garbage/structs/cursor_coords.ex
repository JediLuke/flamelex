defmodule Flamelex.GUI.Structs.CursorCoords do
  @moduledoc """
  Struct which holds grid coordinates, e.g row 0, col 0.
  """
  use Flamelex.ProjectAliases

  defstruct [line: 0, col: 0]


  def new(:first_block) do
    %__MODULE__{
      line: 1,
      col: 0
    }
  end
end

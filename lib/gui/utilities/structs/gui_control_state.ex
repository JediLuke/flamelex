defmodule Flamelex.GUI.Structs.GUIControlState do
  @moduledoc """
  Struct which holds the state of the `GUI.Controller`.
  """
  use Flamelex.ProjectAliases


  @fields [
    viewport: %Dimensions{},
      layout: %Layout{},
       graph: %Scenic.Graph{}
  ]

  defstruct @fields

  @doc """
  Return the default initial state for the `GUI.Controller`
  """
  def initialize(%Dimensions{} = vp) do
    %__MODULE__{
      viewport: vp,
      layout: Layout.default(vp),
      graph: Draw.blank_graph()
    }
  end
end

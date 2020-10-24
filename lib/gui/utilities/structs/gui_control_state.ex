defmodule Flamelex.GUI.Structs.GUIControlState do
  @moduledoc """
  Struct which holds the state of the `GUI.Controller`.
  """
  use Flamelex.ProjectAliases

  @valid_modes [
    :edit, :command, :select
  ]


  @components [
    viewport: nil, # %Dimensions{},
      layout: nil, # %Layout{},
       graph: nil, # %Scenic.Graph{},
        mode: nil
  ]

  defstruct @components

  @doc """
  Return the default initial state for the `GUI.Controller`
  """
  def initialize(%Dimensions{} = vp) do
    %__MODULE__{
      viewport: vp,
      layout: Layout.default(vp),
      graph: Draw.blank_graph(),
      mode: :edit
    }
  end
end

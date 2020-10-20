defmodule Flamelex.GUI.Structs.Layout do
  @moduledoc """
  A layout contains many frames, and their spacial arrangement on the
  screen. It also can show/hide frames, animate frames or frame-decorations,
  or highlight certain parts of the overall canvas.
  """
  require Logger
  use Flamelex.ProjectAliases

  @valid_layouts [
    :maximized,
    :split_pane,
    :floating_frames
  ]

  defstruct [
    dimensions:   nil,
    frames:       [],
    arrangement:  nil,
    opts:         %{}
  ]


  def default(dim) do
    %__MODULE__{
      dimensions:  dim |> Dimensions.new(),
      frames:      [],
      arrangement: :maximized,
      opts:        %{show_menubar?: true}
    }
  end


  ## private functions
  ## -------------------------------------------------------------------


end

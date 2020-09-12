defmodule Flamelex.GUI.Structs.Layout do
  @moduledoc """
  A layout contains many frames, and their spacial arrangement on the
  screen. It also can show/hide frames, animate frames or frame-decorations,
  or highlight certain parts of the overall canvas.
  """
  require Logger
  use Flamelex.CommonDeclarations


  defstruct [
    dimensions:  %Dimensions{},
    frames:      [],
    arrangement: :one_frame_maximum_size
  ]


  def default(dim) do
    %__MODULE__{
      dimensions:  dim |> Dimensions.new(),
      frames:      [],
      arrangement: :floating_frames
    }
  end


  ## private functions
  ## -------------------------------------------------------------------


end

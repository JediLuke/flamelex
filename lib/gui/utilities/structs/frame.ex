defmodule GUI.Structs.Frame do
  @moduledoc """
  Struct which holds relevant data for rendering a buffer frame status bar.
  """
  require Logger
  use Franklin.Misc.CustomGuards
  alias GUI.Structs.{Coordinates, Dimensions}
  alias Structs.Buffer


  defstruct [
    id:          nil,
    coordinates: %Coordinates{},
    dimensions:  %Dimensions{},
    scenic_opts: []
  ]


  #TODO really this should accept a %Coordinates{} and a %Dimensions{}
  def new([id: id, top_left_corner: c, dimensions: d]) do
    %__MODULE__{
      id: id,
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new()
    }
  end
  def new(top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d) do
    %__MODULE__{
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new()
    }
  end
  def new(%Buffer{} = _buf, top_left_corner: {_x, _y} = c, dimensions: {_w, _h} = d, opts: o)  when is_list(o) do #TODO do we need buffer here?
    %__MODULE__{
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new(),
      scenic_opts: o
    }
  end


  ## private functions
  ## -------------------------------------------------------------------


end

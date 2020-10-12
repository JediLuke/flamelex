defmodule Flamelex.GUI.Structs.Frame do
  @moduledoc """
  Struct which holds relevant data for rendering a buffer frame status bar.
  """
  require Logger
  use Flamelex.ProjectAliases

  #TODO each "new/x" function should be making a new Scenic.Graph, we need
  # to actually build one and cant just use a default struct cause it spits chips

  defstruct [
    id:            nil,               # uniquely identify frames
    #TODO rename to top_left
    coordinates:   nil, # %Coordinates{},    # the top-left corner of the frame, referenced from top-left corner of the viewport
    dimensions:    nil, # :w%Dimensions{},     # the height and width of the frame
    scenic_opts:   [],                # Scenic options
    # picture_graph: %Scenic.Graph{}    # The Scenic.Graph that this frame will display
    buffer:        nil
  ]

  def new(
    top_left_corner: %Coordinates{} = c,
    dimensions:      %Dimensions{}  = d
  ) do
    %__MODULE__{
      coordinates: c,
      dimensions:  d
    }
  end

  def new(top_left: top_left, size: size) do
    %__MODULE__{
      id:          "#TODO",
      coordinates: top_left |> Coordinates.new(),
      dimensions:  size     |> Dimensions.new()
    }

  end

  #TODO do we really need an id?? (probably)
  def new(id:              id,
          top_left_corner: %Coordinates{} = c,
          dimensions:      %Dimensions{}  = d
  ) do
    %__MODULE__{
      id:          id,
      coordinates: c,
      dimensions:  d
    }
  end

  #TODO deprecate this too
  # def new([id: id, top_left_corner: c, dimensions: d, picture_graph: g]) do
  def new([id: id, top_left_corner: c, dimensions: d, buffer: b]) do
    %__MODULE__{
      id: id,
      coordinates: c |> Coordinates.new(),
      dimensions:  d |> Dimensions.new(),
      # picture_graph: g
      buffer: b
    }
  end

  #TODO deprecate these
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

  def find_center(%__MODULE__{coordinates: c, dimensions: d}) do
    Coordinates.new([
      x: c.x + d.width/2,
      y: c.y + d.height/2,
    ])
  end

  def reposition(%__MODULE__{coordinates: coords} = frame, x: new_x, y: new_y) do
    new_coordinates =
      coords
      |> Coordinates.modify(x: new_x, y: new_y)

    %{frame|coordinates: new_coordinates}
  end
end

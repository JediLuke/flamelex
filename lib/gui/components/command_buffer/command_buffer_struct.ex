# defmodule GUI.Component.CommandBuffer.Struct do
#   @moduledoc """
#   Struct which holds the CommandBuffer state.
#   """
#   use Franklin.Misc.CustomGuards
#   alias GUI.Structs.{Coordinates, Dimensions, ScenicComponentOptions}

#   defstruct [
#     coordinates: %Coordinates{},
#     dimensions:  %Dimensions{},
#     scenic_opts: %ScenicComponentOptions{},
#     contents:    nil
#   ]

#   def new(%Structs.Buffer{type: :command} = buf, opts) do
#     %__MODULE__{
#       coordinates: buf.coordinates,
#       dimensions:  buf.dimensions,
#       scenic_opts: opts,
#       contents:    buf.contents
#     }
#   end
# end

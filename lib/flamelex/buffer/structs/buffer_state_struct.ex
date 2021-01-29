defmodule Flamelex.Buffer.Structs.BufferState do
  @moduledoc """
  This state is simply a structure used by Buffer processes to keep track
  of their internal state.

  Unlike a %BufRef{} struct, which does get passed around (as a reference
  to a buffer) this struct should only ever be used by Buffer processes.
  """

  defstruct [
    label:              nil,    # an optional text label, sometimes used to hold the title
    ref:                nil,    # the tag which uniquely identifies this buffer, e.g. {:file, "some/path"}
    data:               nil,    # the raw data
    unsaved_changes?:   nil     # a flag to say if we have unsaved changes
  ]

  def new!(%{ref: ref, data: data}) do
    %__MODULE__{
      label: nil,
      # unsaved_changes?:
      # flags?:
      ref: ref,
      data: data
    }
  end
end

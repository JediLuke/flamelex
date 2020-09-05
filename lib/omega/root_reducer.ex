defmodule Flamelex.Buffer.RootReducer do
  @moduledoc """
  The Omega buffer holds all global state, acts as a conduit for all
  user-input, and manages input modes. This RootReducer,

    a) transforms that same root state which was the input, into an
       updated root state
    b) fires off any side-effects that need to be triggered, such as
       forwarding input to a specific buffer, or causing a redraw of the GUI

  """
  use Flamelex.CommonDeclarations
  alias Flamelex.Structs.OmegaState

  def identity(%OmegaState{} = omega) do
    omega
  end
end

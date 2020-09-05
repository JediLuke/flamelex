defmodule Flamelex.Structs.OmegaState do
  @moduledoc false

  # @valid_modes [:normal, :command, :select] #TODO validate the modes

  defstruct [
    mode: :normal,       # The input mode
    input: %{
      history: []        # A list of all previous input events
    }
  ]

  def new do
    %__MODULE__{}
  end
end

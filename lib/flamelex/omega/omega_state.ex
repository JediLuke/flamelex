defmodule Flamelex.Structs.OmegaState do
  @moduledoc false
  use Flamelex.ProjectAliases

  @valid_modes [:normal, :command, :select]

  defstruct [
    mode:           :normal,    # The input mode
    #TODO just a list of input_history, no need for the map
    input: %{
      history:      []          # A list of all previous input events
    },
    active_buffer:  nil         # We need to know the active buffer
  ]

  def init do
    %__MODULE__{
      mode: :normal
    }
  end

  def set(%__MODULE__{} = omega_state, mode: new_mode) when new_mode in @valid_modes do
    #TODO should be done with changesets...
    %{omega_state|mode: new_mode}
  end

  #TODO cap the length of this list
  def add_to_history(omega, input) do
    put_in(omega.input.history, omega.input.history ++ [input])
  end
end

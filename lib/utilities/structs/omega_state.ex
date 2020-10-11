defmodule Flamelex.Structs.OmegaState do
  @moduledoc false
  use Flamelex.ProjectAliases

  @valid_modes [:normal, :command, :select]

  defstruct [
    mode:       :normal,                # The input mode
    # buffers:    [],                     # This is a list of buffers
    input: %{
      history:  []                      # A list of all previous input events
    }
  ]

  def init do
    viewport_size = Dimensions.new(:viewport_size)

    %__MODULE__{
      # gui: %{
      #   viewport: viewport_size,
      #     layout: Layout.default(viewport_size),
      #      graph: Draw.blank_graph()
      # }
    }
  end

  def set(%__MODULE__{} = omega_state, mode: new_mode) when new_mode in @valid_modes do
    #TODO should be done with changesets...
    %{omega_state|mode: new_mode}
  end
end

defmodule GUI.Structs.RootScene do
  @moduledoc """
  Struct which holds 2d points.
  """
  use Franklin.Misc.CustomGuards

  defstruct [
    viewport: %{      # Holds the viewport info (comes when GUI app starts)
      width: nil,
      height: nil
    },
    buffers: [],      # A list of references to buffers
    input: %{
      mode: :normal,  # The input mode must be held in the root state because we pipe input through this process, and the input mode modifies what effects that input has (obviously)
      history: []     # A list which holds the previous inputs (used for chaining inputs together)
    }
  ]

  def new(opts) do
    %__MODULE__{
      viewport: fetch_viewport_info(opts),
    }
  end


  defp fetch_viewport_info(opts) do
    {:ok, %Scenic.ViewPort.Status{ size:
      { viewport_width, viewport_height }}} =
                          opts[:viewport]
                          |> Scenic.ViewPort.info()

    %{width: viewport_width, height: viewport_height}
  end
end

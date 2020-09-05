defmodule GUI.Structs.RootScene do
  @moduledoc false
  alias Flamelex.GUI.Structs.Layout

  defstruct [
    viewport: %{      # Holds the viewport info (comes when GUI app starts)
      width: nil,
      height: nil
    },
    layout: %Layout{}
  ]

  def new(opts) do
    viewport_info = fetch_viewport_info(opts)

    %__MODULE__{
      viewport: viewport_info,
      layout: Layout.default(viewport_info)
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

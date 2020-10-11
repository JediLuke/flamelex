defmodule Flamelex.GUI.Component.TransmutationCircle do
  @moduledoc false
  use Scenic.Component
  use Flamelex.ProjectAliases
  require Logger


  @impl Scenic.Component
  def verify(%Coordinates{} = coords), do: {:ok, coords}
  def verify(_else), do: :invalid_data

  @impl Scenic.Component
  def info(_data), do: ~s(Invalid data)


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl Scenic.Scene
  def init(%Coordinates{} = position, _opts) do
    Logger.debug "#{__MODULE__} initializing..."
    {:ok, %{}, push: draw_circle(position)}
  end

  @doc """
  Append a TranscmutationCircle graph (as in, the %Scenic.Graph{} struct
  representing the circle) to an existing Scenic graph (the first param).

  #TODO use the concept of layers in the Root scene - this layer is always
  top, it's the screensaver

  """
  def draw(%Scenic.Graph{} = graph, viewport: %Dimensions{} = vp) do
    center_screen = Dimensions.find_center(vp)

    graph
    |> add_to_graph(center_screen) # REMINDER: this ends up calling verify/1 to check the params (in our case, the %Dimensions{} struct representing center-screen), which gets passed into this module's init/1
  end


  ## private functions


  defp draw_circle(position) do
    Draw.blank_graph()
    |> Draw.box(
              x: position.x,
              y: position.y,
          width: 100,
         height: 100)
  end
end

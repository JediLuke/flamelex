defmodule GUI.Component.ColoredBox do
  @moduledoc false
  use Scenic.Component
  alias GUI.Structs.{Coordinates, Dimensions}
  alias Scenic.Graph
  import Scenic.Primitives


  defguard is_positive_integer(x) when is_integer(x) and x >= 0
  defguard all_positive_integers(a, b, c, d) when is_positive_integer(a) and is_positive_integer(b) and is_positive_integer(c) and is_positive_integer(d)
  defguard all_positive_integers(a, b, c, d, e) when all_positive_integers(a, b, c, d) and is_positive_integer(e)
  defguard all_atoms(a, b) when is_atom(a) and is_atom(b)


  # --------------------------------------------------------------------
  # defmodule State do
  #   defstruct coordinates: Coordinates.initialize({0, 0}),
  #             dimensions: Dimensions.initialize({0, 0})
  # end


  # --------------------------------------------------------------------
  @doc false
  def verify([coordinates: {x, y}, dimensions: {w, h}, color: c] = data) when all_positive_integers(x, y, w, h) and is_atom(c) do #TODO check the atom is a valid color
    {:ok, data}
  end
  def verify([coordinates: {x, y}, dimensions: {w, h}, color: c, stroke: {s, c2}] = data) when all_positive_integers(x, y, w, h, s) and all_atoms(c, c2) do #TODO check the atom is a valid color
    {:ok, data}
  end
  def verify(_), do: :invalid_data


  # --------------------------------------------------------------------
  @doc false
  def info(data) do
    """
    #{IO.ANSI.red()}#{__MODULE__} data must be: [coordinates: {x, y}, dimensions: {w, h}]
    All integers must be greater than zero.
    #{IO.ANSI.yellow()}Received: #{inspect(data)}
    #{IO.ANSI.default_color()}
    """
  end


  def add_box(graph, data) do
    graph |> __MODULE__.add_to_graph(data)
  end


  # --------------------------------------------------------------------
  @doc false
  def init(data, _opts) do
    graph = data |> initialize_graph
    GenServer.call(GUI.Scene.Root, {:register, :box1})
    {:ok, %{}, push: graph}
  end


  defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c) do
    Graph.build()
    |> rect({w, h}, translate: {x, y}, fill: c)
  end
  defp initialize_graph(coordinates: {x, y}, dimensions: {w, h}, color: c, stroke: {s, border_color}) do
    Graph.build()
    |> rect({w, h}, translate: {x, y}, fill: c, stroke: {s, border_color})
  end
end

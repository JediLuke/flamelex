defmodule Flamelex.GUI.Component.TransmutationCircle do
  @moduledoc """
  In order to begin an alchemical transmutation, a symbol called a
  Transmutation Circle (錬成陣, Renseijin) is necessary. A Transmutation
  Circle can either be drawn on the spot when a transmutation is necessary
  (in chalk, pencil, ink, paint, thread, blood or even traced in dirt) or
  permanently etched or inscribed beforehand, but without it, transmutation
  is generally impossible.

  All Transmutation Circles are made up of two parts:

    1)  The circle itself is a conduit which focuses and dictates the
        flow of power, tapping into the energies that already exist
        within the earth and matter. It represents the cyclical flow of
        the world's energies and phenomena and turns that power to
        manipulable ends.

    2) Inside the circle are specific alchemical runes. These runes vary
       widely based on ancient alchemical studies, texts, and experimentation,
       but correspond to a different form of energy, allowing the energy
       that is focused within the circle to be released in the way most
       conducive to the alchemist's desired effect. In basic alchemy, these
       runes will often take the form of triangles (which, when positioned
       differently, can represent the elements of either water, earth,
       fire or air), but will often be composed of varying polygons built
       from different triangles. For example, the hexagram is a commonly
       used base rune in Transmutation Circles because it creates eight
       multi-directional triangles when inscribed and can, therefore,
       represent all four classical elements at once. Other, more esoteric
       runes (including astrological symbols, symbolic images and varying
       lines of text) are prevalent and represent a multitude of other,
       specific functions for the alchemical energy that is released.

    - https://fma.fandom.com/wiki/Alchemy
  """
  # use Flamelex.GUI.ComponentBehaviour
  use Scenic.Component
  alias Flamelex.GUI.GeometryLib.Trigonometry
  alias Flamelex.GUI.Structs.Frame

  @primary_color :dark_violet

  def validate(data) do
    {:ok, data}
  end

  def mount(%Scenic.Graph{} = graph, %{ref: r} = params) do
    graph |> add_to_graph(params, id: r) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  end
  def mount(%Scenic.Graph{} = graph, params) do
    graph |> add_to_graph(params) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  end


  def init(scene, params, opts) do

    # IO.inspect params
    # IO.inspect opts
    # Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    new_graph = 
      render(params.frame, %{})
      # |> Scenic.Primitives.text("Lukey", font: :ibm_plex_mono, t: {200, 200}, font_size: 24, fill: :white)
#                     translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#                     font_size: 24, fill: :black)
      # Scenic.Graph.build()
      # |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})
    # # new_scene =
      scene
    #   # |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:ok, scene}
  end

  def rego_tag(_), do: {:gui_component, :renseijin}

  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do


    # |> Draw.background(frame, @primary_color)

    params = %{
      radius: frame.dimensions.width/2, # we can get the scale_factor back this way!
      center: Frame.find_center(frame),
      outer_rim: 42,
      gap_size: 4
    }

    Scenic.Graph.build()
    |> Scenic.Primitives.group(fn graph ->
          graph
          |> draw_circles(params)
          |> draw_triangles(params)
       end, [
          id: __MODULE__,
          hidden: false
       ])
  end

  def draw_circles(graph, params) do
    %{
      radius: radius,
      center: center,
      outer_rim: rim,
      gap_size: size
    } = params

    graph
    |> Scenic.Primitives.circle(radius,
                stroke: {1, @primary_color},
                translate: {center.x, center.y})
    |> Scenic.Primitives.circle(radius - rim + size,
                stroke: {1, @primary_color},
                translate: {center.x, center.y})
    |> Scenic.Primitives.circle(radius - rim + 2 * size + size/2,
                stroke: {1, @primary_color},
                translate: {center.x, center.y})
  end

  def draw_triangles(graph, params) do
    %{
      radius: radius,
      center: center,
      outer_rim: rim,
      gap_size: size
    } = params

    graph
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius),
                stroke: {1, @primary_color})
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - rim + size),
                stroke: {1, @primary_color})
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - rim + 2 * size + size/2),
                stroke: {1, @primary_color})
  end


  def show do

  end

  def hide do

  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_state, _graph}, :hide) do
    raise "Can't hide TransmutationCircle yet"
  end

  def kaomoji do
    "☆*:.｡.o(≧▽≦)o.｡.:*☆"
  end
end

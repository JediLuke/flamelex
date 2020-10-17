defmodule Flamelex.GUI.Component.TransmutationCircle do #TODO rename to Renseijin
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
  use Flamelex.GUI.ComponentBehaviour
  alias Flamelex.GUI.GeometryLib.Trigonometry

  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    radius = frame.dimensions.width/2 # we can get the scale_factor back this way!
    center = Frame.find_center(frame)

    outer_rim = 42
    gap_size = 4

    Draw.blank_graph()
    # |> Draw.background(frame, :purple)

    # circles
    |> Scenic.Primitives.circle(radius,
                stroke: {1, :white},
                translate: {center.x, center.y})
    |> Scenic.Primitives.circle(radius - outer_rim + gap_size,
                stroke: {1, :white},
                translate: {center.x, center.y})
    |> Scenic.Primitives.circle(radius - outer_rim + 2 * gap_size + gap_size/2,
                stroke: {1, :white},
                translate: {center.x, center.y})

    # triangles
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius),
                stroke: {1, :white})
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - outer_rim + gap_size),
                stroke: {1, :white})
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - outer_rim + 2 * gap_size + gap_size/2),
                stroke: {1, :white})

  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_state, _graph}, :hide) do
    raise "Can't hide TransmutationCircle yet"
  end

  def kaomoji do
    "☆*:.｡.o(≧▽≦)o.｡.:*☆"
  end
end

defmodule Flamelex.GUI.Renseijin do
  @moduledoc """
  This module provides a nice CLAPI (Command-line API) - intended to be
  used by a programmer via IEx.
  """
  require Logger
  use Flamelex.ProjectAliases

  def transmote do
    {:ok, pid} =
      Flamelex.GUI.Component.TransmutationCircle.rego_tag(%{})
      |> ProcessRegistry.lookup()

    GenServer.cast(pid, :transmotion_begin)

    Logger.info "~~ Double, double toil and trouble; Fire burn and caldron bubble ~~"
  end
end

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
  alias ScenicWidgets.Core.Structs.Frame
  require Logger

  @primary_color :dark_violet
  @pi 3.14159265359

  def validate(%{ref: r} = data) do
    #Logger.debug "#{__MODULE__} has valid input data."
    {:ok, data}
  end

  def mount(%Scenic.Graph{} = graph, %{ref: r} = params) do
    graph |> add_to_graph(params, id: r) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  end
  def mount(%Scenic.Graph{} = graph, params) do
    graph |> add_to_graph(params) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
  end


  def init(scene, params, opts) do
    Logger.debug "#{__MODULE__} initializing..."
    # Process.register(self(), __MODULE__)
    # Flamelex.GUI.ScenicInitialize.load_custom_fonts_into_global_cache()

    Flamelex.Utils.ProcessRegistry.register(rego_tag())
    #NOTE: `Flamelex.GUI.Controller` will boot next & take control of
    #      the scene, so we just need to initialize it with *something*
    new_graph = 
      render(params.frame, %{})

      # |> Scenic.Primitives.text("Lukey", font: :ibm_plex_mono, t: {200, 200}, font_size: 24, fill: :white)
#                     translate: {25, 50 + offset_count * 110}, # text draws from bottom-left corner?? :( also, how high is it???
#                     font_size: 24, fill: :black)
      # Scenic.Graph.build()
      # |> Scenic.Primitives.rect({80, 80}, fill: :white,  translate: {100, 100})

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(frame: params.frame)
      |> assign(rotation: 0)
      |> assign(transmoting?: false)
      |> push_graph(new_graph)
    
    request_input(new_scene, [:cursor_pos])

    {:ok, new_scene}
  end

  @animation_rate 10 # 100ms framerate? tick every 100ms?

  def handle_cast(:transmotion_begin, %{assigns: %{transmoting?: true}} = scene) do
    #Logger.debug "#{__MODULE__} received msg: :transmotion_begin, but ignoring it because we're already transmoting!"
    {:noreply, scene}
  end

  # A note on a most amusing bug
  #
  # While trying to implement a hover functionality on the Renseijin, I
  # wanted to make it tramsmote whenever we hovered over the center. So,
  # I set it up to call 'transmote begin" whenever it detected that happen -
  # the GUI component would call this function
  #
  # At the time, before we had the guard above, this would just immediately
  # call this handle_cast, which would immediately start a NEW timer -
  # effectively doubling the clock speed of the animation!
  #
  # At first I thought this was quite a cool effect - I overcoupled it
  # to something else, which was how fast I was moving my mouse, and I
  # thought I had somehow introduced a pseudo-random element to how fast
  # the animation would occur, based on moving the mouse in and out - and
  # I experimented with this for a while - it seemed that as we moved in,
  # it got faster & faster, until it started to slow again (presumably when
  # I pulled the mouse away), and then it sort of just stayed slow no matter
  # what I could do... eventually I realised that I was first flooding
  # the process with timer messages (thus increasing animation speed) up
  # until a point, whereupon the animation began to SLOW again, probably
  # because it had a big backlock of messages!
  #
  # Remember kids, guards are good, but they don't eliminate all bugs!

  def handle_cast(:transmotion_begin, scene) do
    #Logger.debug "#{__MODULE__} received msg: :transmotion_begin"
    {:ok, timer} = :timer.send_interval(@animation_rate, :animation_tick)
    new_scene = scene
    |> assign(transmoting?: true)
    |> assign(timer: timer)
    {:noreply, new_scene}
  end

  def handle_cast(:transmotion_halt, %{assigns: %{transmoting?: true, timer: timer}} = scene) do
    #Logger.debug "#{__MODULE__} received msg: :transmotion_halt"
    :timer.cancel(timer)
    new_scene = scene
    |> assign(timer: nil)
    |> assign(transmoting?: false)
    {:noreply, new_scene}
  end

  def handle_cast(:transmotion_halt, scene) do
    #Logger.debug "#{__MODULE__} received msg: :transmotion_halt, ignoring it completely..."
    {:noreply, scene}
  end


  def rego_tag, do: {:gui_component, :renseijin}
  def rego_tag(_), do: rego_tag()

  @impl Flamelex.GUI.ComponentBehaviour
  # def render(%{assigns: %{graph: graph, rotation: r, frame: frame}} = scene) do
  #   params = %{
  #     radius: frame.dimensions.width/2, # we can get the scale_factor back this way!
  #     center: Frame.find_center(frame),
  #     outer_rim: 42,
  #     gap_size: 4,
  #     rotation: r
  #   }
  #   Scenic.Graph.build()
  #   |> Scenic.Primitives.group(fn graph ->
  #         graph
  #         |> draw_circles(params)
  #         |> draw_triangles(params)
  #      end, [
  #         id: __MODULE__,
  #         hidden: false
  #      ])
  # end
  def render(frame, _params) do


    # |> Draw.background(frame, @primary_color)

    params = %{
      radius: frame.dimensions.width/2, # we can get the scale_factor back this way!
      center: Frame.find_center(frame),
      outer_rim: 42,
      gap_size: 4,
      rotation: 0
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
    |> Scenic.Primitives.circle(radius-170,
                id: :inner_circle,
                hidden: true,
                stroke: {1, @primary_color},
                translate: {center.x, center.y})
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
      gap_size: size,
      rotation: r
    } = params

    graph
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius),
                id: :inner_triangle,
                stroke: {1, @primary_color})
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - rim + size),
                id: :mid_triangle,
                stroke: {1, @primary_color},
                rotate: r)
    |> Scenic.Primitives.triangle(
                Trigonometry.equilateral_triangle_coords(
                  center,
                  radius - rim + 2 * size + size/2),
                id: :outer_triangle,
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

  def handle_info(:animation_tick, %{assigns: %{rotation: r}} = scene)
    when scene.assigns.rotation >= 0 and scene.assigns.rotation <= 360 do
      # Logger.debug "#{__MODULE__} received: :animation_tick"

      scene = scene
      |> assign(rotation: scene.assigns.rotation + 0.2)

      new_graph =
        scene.assigns.graph
        |> Scenic.Graph.modify(:inner_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))
        |> Scenic.Graph.modify(:mid_triangle, &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(scene.assigns.rotation)))
        |> Scenic.Graph.modify(:outer_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))

      new_scene =
        scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)
    
    {:noreply, new_scene}
  end

  def handle_info(:animation_tick, %{assigns: %{rotation: r}} = scene) do
      # Logger.debug "#{__MODULE__} received: :animation_tick - and we need to reset our timer!"

      scene = scene
      |> assign(rotation: 0)

      new_graph =
        scene.assigns.graph
        |> Scenic.Graph.modify(:inner_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))
        |> Scenic.Graph.modify(:mid_triangle, &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(scene.assigns.rotation)))
        |> Scenic.Graph.modify(:outer_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))

      new_scene =
        scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)
    
    {:noreply, new_scene}
  end


  @cool_kid_radius 80 # area of effect for awesomeness to happen
  def handle_input({:cursor_pos, {x, y}}, _context, %{assigns: %{frame: frame}} = scene) do
    centerpoint = Frame.find_center(frame)
    #Logger.debug "#{__MODULE__} handling cursor_pos - centerpoint: #{inspect centerpoint}"
    if {x, y} |> within_box?(centerpoint, @cool_kid_radius) do
      Flamelex.GUI.Renseijin.transmote()
      {:noreply, scene}
    else
      #Logger.debug "#{__MODULE__} detected cursor_pos `#{inspect {x, y}}`, and classified it as: outside the inner radius"
      GenServer.cast(self(), :transmotion_halt)
      {:noreply, scene}
    end
  end

  def within_box?({query_x, query_y}, %{x: base_x, y: base_y}, radius) do
    low_x = base_x - radius
    low_y = base_y - radius
    high_x = base_x + radius
    high_y = base_y + radius

    # IO.inspect low_x
    # IO.inspect query_x
    # IO.inspect high_x
    t1 = low_x <= query_x
    # IO.inspect t1, label: "t1"
    t2 = query_x <= high_x
    # IO.inspect t2, label: "t2"
    t3 = (low_x <= query_x <= high_x)
    # IO.inspect t3, label: "t3"
    t4 = t1 and t2
    # IO.inspect t4, label: "t4"

    #NOTE: We need to split them up into specific queries, unfortunately
    #      it looks like `(low_x <= query_x <= high_x)` type queries
    #      don't work that way in Elixir
    (low_x <= query_x) and (query_x <= high_x) and (low_y <= query_y) and (query_y <= high_y)
  end

  # def within_radius?({query_x, query_y}, {base_x, base_y}, radius) do
  #   raise "need to re-math again"
  # end


  def degree_in_radians(x) do
    (2*@pi*x)/360
  end

  def kaomoji do
    "☆*:.｡.o(≧▽≦)o.｡.:*☆"
  end
end

defmodule Flamelex.GUI.Component.Renseijin do
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
   use Scenic.Component
   alias ScenicWidgets.Core.Structs.Frame
   require Logger

   @primary_color :dark_violet
   @pi 3.14159265359
   @animation_rate 10 # 100ms framerate? tick every 100ms?
   @cool_kid_radius 80 # area of effect for awesomeness to happen

   def validate(%{frame: %Frame{} = _f, animate?: animate?} = data) when is_boolean(animate?) do
      #Logger.debug "#{__MODULE__} has valid input data."
      {:ok, data}
   end


   def init(scene, args, opts) do
      Logger.debug "#{__MODULE__} initializing..."

      Process.register(self(), __MODULE__)

      new_graph = render(args.frame)

      new_scene =
         scene
         |> assign(graph: new_graph)
         |> assign(frame: args.frame)
         |> assign(rotation: 0)
         |> assign(animate?: args.animate?)
         |> push_graph(new_graph)
      
      request_input(new_scene, [:cursor_pos])

      {:ok, new_scene}
   end

   def handle_cast(:start_animation, %{assigns: %{animate?: true}} = scene) do
      #Logger.debug "#{__MODULE__} received msg: :start_animation, but ignoring it because we're already animated..."
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

   def handle_cast(:start_animation, scene) do
      #Logger.debug "#{__MODULE__} received msg: :transmotion_begin"
      {:ok, timer} = :timer.send_interval(@animation_rate, :tick)
      new_scene = scene
      |> assign(animate?: true)
      |> assign(timer: timer)
      {:noreply, new_scene}
   end

   def handle_cast(:stop_animation, %{assigns: %{animate?: true, timer: timer}} = scene) do
      #Logger.debug "#{__MODULE__} received msg: :transmotion_halt"
      :timer.cancel(timer)
      new_scene = scene
      |> assign(timer: nil)
      |> assign(animate?: false)
      {:noreply, new_scene}
   end

   def handle_cast(:stop_animation, scene) do
      #Logger.debug "#{__MODULE__} received msg: :transmotion_halt, ignoring it completely..."
      {:noreply, scene}
   end

   def handle_cast(:reset_animation, scene) do
      #Logger.debug "#{__MODULE__} received msg: :transmotion_halt, ignoring it completely..."

      scene =
         scene
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

   def handle_cast({:redraw, args}, scene) do
      new_graph = render(args.frame)

      new_scene =
         scene
         |> assign(graph: new_graph)
         |> assign(frame: args.frame)
         |> assign(animate?: args.animate?)
         |> push_graph(new_graph)
      
      {:noreply, new_scene}
   end

   def handle_info(:tick, %{assigns: %{rotation: r}} = scene)
      when scene.assigns.rotation >= 0 and scene.assigns.rotation <= 360 do
         # Logger.debug "#{__MODULE__} received: :tick"

         scene =
            scene
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

   # def handle_info(:tick, %{assigns: %{rotation: r}} = scene) do
   #       # Logger.debug "#{__MODULE__} received: :tick - and we need to reset our timer!"

   #       scene = scene
   #       |> assign(rotation: 0)

   #       new_graph =
   #       scene.assigns.graph
   #       |> Scenic.Graph.modify(:inner_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))
   #       |> Scenic.Graph.modify(:mid_triangle, &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(scene.assigns.rotation)))
   #       |> Scenic.Graph.modify(:outer_triangle, &Scenic.Primitives.update_opts(&1, rotate: -1*degree_in_radians(scene.assigns.rotation)))

   #       new_scene =
   #       scene
   #       |> assign(graph: new_graph)
   #       |> push_graph(new_graph)
      
   #    {:noreply, new_scene}
   # end

   def handle_input({:cursor_pos, {x, y}}, _context, %{assigns: %{frame: frame}} = scene) do
      centerpoint = Frame.center(frame)
      #Logger.debug "#{__MODULE__} handling cursor_pos - centerpoint: #{inspect centerpoint}"
      if {x, y} |> within_box?(centerpoint, @cool_kid_radius) do
         GenServer.cast(self(), :start_animation)
         {:noreply, scene}
      else
         #Logger.debug "#{__MODULE__} detected cursor_pos `#{inspect {x, y}}`, and classified it as: outside the inner radius"
         GenServer.cast(self(), :stop_animation)
         {:noreply, scene}
      end
   end

   def render(frame) do
      args = %{
         radius: frame.dimens.width/2*0.37, # we can get the scale_factor back this way!
         center: center = Frame.center(frame),
         outer_rim: 42,
         gap_size: 4,
         rotation: 0
      }

      Scenic.Graph.build()
      |> Scenic.Primitives.group(fn graph ->
            graph
            |> draw_circles(args)
            |> draw_triangles(args)
            |> draw_taijitu(args)
         end, [
            id: __MODULE__,
            hidden: false,
            translate: {center.x, center.y}
         ])
   end

   def draw_circles(graph, args) do
      %{
         radius: outer_radius,
         outer_rim: rim,
         gap_size: size
      } = args

      graph
      # |> Scenic.Primitives.circle(inner_circle_radius(outer_radius),
      #             id: :inner_circle,
      #             hidden: true,
      #             stroke: {1, @primary_color})
      |> Scenic.Primitives.circle(outer_radius, stroke: {1, @primary_color})
      |> Scenic.Primitives.circle(inner_circle_radius(args), stroke: {1, @primary_color})
      |> Scenic.Primitives.circle(inner_circle_radius(args) + 1.5*size, stroke: {1, @primary_color})
   end

   def draw_triangles(graph, args) do
      %{
         radius: radius,
         center: center,
         outer_rim: rim,
         gap_size: size,
         rotation: r
      } = args

      graph
      |> Scenic.Primitives.triangle(
                  equilateral_triangle_coords(radius),
                  id: :inner_triangle,
                  stroke: {1, @primary_color})
      |> Scenic.Primitives.triangle(
                  equilateral_triangle_coords(radius-rim+size),
                  id: :mid_triangle,
                  stroke: {1, @primary_color},
                  rotate: r)
      |> Scenic.Primitives.triangle(
                  equilateral_triangle_coords(radius-rim+(2.5*size)),
                  id: :outer_triangle,
                  stroke: {1, @primary_color})
   end

   def equilateral_triangle_coords(radius) do
      {
         {(-1*:math.sqrt(3)) * radius/2, radius/2},
         {0, -1*radius},
         {:math.sqrt(3) * radius/2, radius/2}
      }
   end

   def draw_taijitu(graph, args) do
      radius = inner_circle_radius(args)/2

      graph
      # |> Scenic.Primitives.line({{0, -radius}, {0, radius}}, stroke: {1, :grey})
      # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey})
      # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey}, translate: {0, -radius/2})
      # |> Scenic.Primitives.line({{-5, 0}, {5, 0}}, stroke: {1, :grey}, translate: {0, radius/2})
      |> Scenic.Primitives.circle(radius/6, stroke: {1, :grey}, translate: {0, -radius/2})
      |> Scenic.Primitives.circle(radius/6, stroke: {1, :grey}, translate: {0, radius/2})
      |> Scenic.Primitives.arc({radius/2, @pi}, stroke: {1, :grey}, rotate: 3*@pi/2, translate: {0, -radius/2})
      |> Scenic.Primitives.arc({radius/2, @pi}, stroke: {1, :grey}, rotate: @pi/2, translate: {0, radius/2})
      |> Scenic.Primitives.circle(radius, stroke: {1, :grey})
   end

   def inner_circle_radius(%{
      radius: outer_radius,
      outer_rim: rim,
      gap_size: size
   }) do
      # outer_radius - rim + 2 * size + size/2
      outer_radius - rim + size
   end

   def within_box?({query_x, query_y}, %{x: base_x, y: base_y}, radius) do
      low_x = base_x - radius
      low_y = base_y - radius
      high_x = base_x + radius
      high_y = base_y + radius

      (low_x <= query_x) and (query_x <= high_x) and (low_y <= query_y) and (query_y <= high_y)
   end

   def degree_in_radians(x) do
      (2*@pi*x)/360
   end

end

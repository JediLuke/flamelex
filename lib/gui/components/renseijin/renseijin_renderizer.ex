defmodule Flamelex.GUI.Components.Renseijin.Rend do
  @doc """
  The unique function which renders the Renseijin component.
  """

  alias Flamelex.GUI.Components.Renseijin

  # a constant for π (change for potentially wacky behaviour~~)
  @pi 3.14159265359
  # The golden ratio - φ (phi) - nature's proportion of divine harmony
  @phi 1.618033988749
  # τ (tau) - the true circle constant, the complete revolution
  @tau 6.283185307179

  @cos30 0.8660254037
  @sin45 0.7071067811
  @e 2.718281828

  @transparent_light_grey {:color_rgba, {211, 211, 211, 37}}
  @really_really_transparent_light_grey {:color_rgba, {211, 211, 211, 17}}

  # it's called `er` because the module is Rend,
  # to together it's Rend.er
  @spec er(Widgex.Frame.t(), Renseijin.State.t()) :: Scenic.Graph.t()
  def er(%Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    Scenic.Graph.build()
    |> draw_background(frame, state)
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> draw_greatsquares(frame, state)
        |> draw_circles(frame, state)
        |> draw_triangles(frame, state)
        |> draw_taijitu(frame, state)
        |> draw_hexagons(frame, state)
        |> draw_outer_circles(frame, state)
        |> draw_conatus_spiral(frame, state)
        |> draw_phi_harmonics(frame, state)
        # |> draw_symbcirclesols(frame, state)
        # |> Utils.draw_squares(frame, state)
        # |> Utils.draw_pyramids(frame, state)
      end,
      id: __MODULE__,
      translate: Widgex.Frame.center(frame).point
    )
    |> Scenic.Graph.modify(:scissor, frame.size.box)
  end

  #############################################################################
  # Draw Background
  # ===========================================================================

    @artificial_manuscript "images/artificial_manuscript.png"
    @artificial_manuscript_dimens {2145, 1218}

    @background_images [
      # "images/jupiter.jpg",
      # "images/milky_way.jpg",
      "images/ngc_4535.jpg",
      # "images/pexels_sunrise.jpg",
      # "images/uluru_sunrise.jpg"
      # "images/uluru-northern-territory-australia-139.jpg"
      "images/burning_man_2016_temple_friday_sunrise.jpeg",
      "images/artificial_manuscript.png"
    ]

    def draw_background(
          %Scenic.Graph{} = graph,
          %Widgex.Frame{} = frame,
          %Renseijin.State{} = state
        ) do
      graph
      |> Scenic.Primitives.rect(frame.size.box,
        # translate: Coordinates.point(frame.pin),
        translate: frame.pin.point,
        fill: {:image, "images/ngc_4535.jpg"}

        #TODO eventually this shouldn't happen cause we wouldn't be re-rendering Renseijin so much,
        # until then it just looks crazy
        # fill: {:image, Enum.random(@background_images)}
      )
      # |> draw_mask_with_gradient(frame, state)

      # |> Scenic.Primitives.rect({100, 50},
      #   fill: {:linear, {50, 25, 10, 45, :blue, :yellow}},
      #   translate: frame.pin.point
      # )
    end

  #############################################################################
  # Draw Hexagon
  # ===========================================================================

  # some AI magix, don't touch
  @magic_coefficient 2 / 3 * (3 / 4) * (2 / 3)
  def draw_hexagons(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)

    # {_stroke, relief_color} = state.relief_stroke
    symbol_color = :antique_white

    graph
    |> draw_hexagon(state, radius: radius / 2)
    |> draw_little_hexagons(frame, state)
    |> draw_little_hexagons(frame, state, 1)
    |> draw_little_hexagons(frame, state, 2)
    |> draw_little_hexagons(frame, state, 3)
    |> draw_little_hexagons(frame, state, 4)
    |> draw_little_hexagons(frame, state, 5)
    |> Scenic.Primitives.text(
      # Zinc, to honour Linus Torvalds - a catalyst for creation
      # (I don't have the Zinc alchemical symbol in a font, so a workaround is required - a beautifully linux-like irony)
      "Ž",
      font_size: 30,
      font: :noto_sans_symbols,
      fill: symbol_color,
      text_align: :center,
      translate: {-@cos30*0.76*radius, -0.38*radius},
      rotate: degree_in_radians(300)
    )

    |> Scenic.Primitives.text(
      # Tin, to honour Joe Armstrong, Robert Virding & Mike Williams - architects of resilience, solidatores of simultaneity
      "🜩",
      font_size: 30,
      # font: :noto_sans_semi_condensed_medium_italic,
      font: :noto_sans_symbols,
      fill: symbol_color,
      text_align: :center,
      # translate: {0, 0.86*radius}
      # # rotate: degree_in_radians(120)
      translate: {@cos30*0.76*radius, -0.38*radius},
      rotate: degree_in_radians(60)
    )
    |> Scenic.Primitives.text(
      # Iron, to honour Richard Stallman - unyielding & unbending in the defense of freedom
      "🜝",
      font_size: 32,
      font: :noto_sans_symbols,
      fill: symbol_color,
      text_align: :center,
      # translate: {-@cos30*0.76*radius, -0.38*radius},
      translate: {0, 0.86*radius}
      # rotate: degree_in_radians(300)
    )

  end

  def draw_little_hexagons(graph, frame, state, n \\ 0) do
    radius = Renseijin.State.inner_radius(frame, state)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> draw_little_hexagon(state, radius: radius / 2)
        |> draw_little_hexagon(state, radius: radius / 4)
        |> draw_little_hexagon(state, radius: radius / 8)
        |> draw_little_hexagon(state, radius: radius / 16)

        # I think the effect is kind of lost after 4
        # |> draw_little_hexagon(state, radius: radius / 32)
      end,
      rotate: n * @pi / 3
    )
  end

  def draw_hexagon(%Scenic.Graph{} = graph, %Renseijin.State{} = state, radius: radius) do
    hexagon_path_elements = hexagon_path_elements(radius)

    graph
    |> Scenic.Primitives.path(
      hexagon_path_elements,
      stroke: state.relief_stroke,
      cap: :round
    )
  end

  def draw_little_hexagon(%Scenic.Graph{} = graph, %Renseijin.State{} = state, radius: radius) do
    hexagon_path_elements = hexagon_path_elements(radius / 2)

    graph
    |> Scenic.Primitives.path(
      hexagon_path_elements,
      stroke: state.relief_stroke,
      cap: :round,
      translate: {0, -radius}
    )
  end

  def hexagon_path_elements(radius) do
    angle_step = :math.pi() / 3

    path_elements =
      Enum.map(0..5, fn i ->
        angle = i * angle_step
        x = :math.cos(angle) * radius
        y = :math.sin(angle) * radius
        {:line_to, x, y}
      end)

    [{:move_to, :math.cos(0) * radius, :math.sin(0) * radius}] ++ path_elements ++ [:close_path]
  end

  #############################################################################
  # Taijitsu
  # ===========================================================================

  def draw_taijitu(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)
    # dot_radii = radius / 2

    graph
    # |> Scenic.Primitives.line({{0, -dot_radii}, {0, dot_radii}}, stroke: {1, :grey})
    |> draw_taijitu_group(frame, state, radius)
    # |> add_taijitu_tails(state, radius)
  end

  def draw_taijitu_group(graph, frame, state, radius) do
    {stroke_w, _yellow} = state.taijitu.stroke

    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            |> Scenic.Primitives.circle(radius / 6,
              stroke: {stroke_w, stroke_color},
              id: :taijitu_tail
            )
            |> Scenic.Primitives.text(
              # this symbol is lowercase "lambda" in greek script
              "λ",
              font_size: 36,
              font: :noto_sans,
              fill: stroke_color,
              text_align: :center,
              translate: {2, 12},
              id: :taijitu_text
            )
          end,
          rotate: -1 * degree_in_radians(state.rotation),
          translate: {0, -radius / 2}
        )
        |> Scenic.Primitives.group(
          fn graph ->
            graph
            |> Scenic.Primitives.circle(radius / 6,
              stroke: {stroke_w, stroke_color},
              id: :taijitu_tail
            )
            |> Scenic.Primitives.text(
              # this symbol is the "eye of horus" in merotic script
              "𐦝",
              font_size: 38,
              font: :meroitic,
              fill: stroke_color,
              text_align: :center,
              translate: {0, 12},
              id: :taijitu_text
            )
          end,
          rotate: -1 * degree_in_radians(state.rotation),
          translate: {0, radius / 2}
        )
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: {stroke_w, stroke_color},
          rotate: 3 * @pi / 2,
          translate: {0, -radius / 2},
          id: :taijitu_tail
        )
        |> Scenic.Primitives.arc({radius / 2, @pi},
          stroke: {stroke_w, stroke_color},
          rotate: @pi / 2,
          translate: {0, radius / 2},
          id: :taijitu_tail
        )
        |> Scenic.Primitives.circle(radius, stroke: {stroke_w, stroke_color}, id: :taijitu_tail)
      end,
      id: :taijitu,
      rotate: degree_in_radians(state.rotation)
    )
  end

  # TODO this should all get cleaned up...
  def add_taijitu_tails(graph, state, inner_radius) do
    width_factor = 6.12
    finish_height = 3 * inner_radius

    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    # same id for both paths, so they can be updated together
    graph
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, inner_radius},
        {:bezier_to, 0.67 * inner_radius * width_factor, inner_radius,
         (1 - 0.67) * inner_radius * width_factor, finish_height, inner_radius * width_factor,
         finish_height}
      ],
      stroke: {state.taijitu.stroke_width, stroke_color},
      id: :taijitu_tail
    )
    |> Scenic.Primitives.path(
      [
        :begin,
        {:move_to, 0, -inner_radius},
        {:bezier_to, -1 * 0.67 * inner_radius * width_factor, -1 * inner_radius,
         -1 * (1 - 0.67) * inner_radius * width_factor, -1 * finish_height,
         -1 * inner_radius * width_factor, -1 * finish_height}
      ],
      stroke: {state.taijitu.stroke_width, stroke_color},
      id: :taijitu_tail
    )
  end

  # TODO this pattern was interesting... explore it later
  # def add_taijitu_tails(graph, width) do
  #   graph
  #   |> Scenic.Primitives.path(
  #     [
  #       :begin,
  #       {:move_to, 0, width},
  #       {:bezier_to, 0, 0, 0, 0, width, 0}
  #       # {:line_to, 300, 600},
  #       # :close_path
  #     ],
  #     #  fill: :white,
  #     # stroke_fill: :yellow,
  #     # stroke_width: 2
  #     stroke: {1, :yellow}
  #   )
  # end

  def eye_width() do
    {:ok, meroitic_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans_Meroitic/NotoSansMeroitic-Regular.ttf")

    FontMetrics.width("𐦝", 40, meroitic_font_metrics)
  end

  def lambda_width() do
    {:ok, noto_sans_font_metrics} =
      TruetypeMetrics.load("./assets/fonts/Noto_Sans/static/NotoSans-Regular.ttf")

    FontMetrics.width("λ", 36, noto_sans_font_metrics)
  end

  def degree_in_radians(x) do
    2 * @pi * x / 360
  end

  # Idea - Erlang styled toolkit where you right click on a supervisor & select 'new genserver' & it autogenerates the code. Then "click to deploy" puts it on Fly.io


  #############################################################################
  # Drawing circles
  # ===========================================================================

  def draw_circles(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    graph
    |> draw_circle(state, Renseijin.State.radius(frame), %{stroke: {
      state.primary_stroke,
      state.primary_color
    }})
    |> draw_circle(state, Renseijin.State.inner_radius(frame, state), %{stroke: {
      state.primary_stroke,
      state.primary_color
    }})
    |> draw_circle(state, Renseijin.State.outer_radius(frame, state), %{stroke: {
      state.primary_stroke,
      state.primary_color
    }})
  end

  def draw_outer_circles(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    factor = 1.72
    graph
    |> draw_circle(state, factor * Renseijin.State.radius(frame), %{stroke: {
      state.primary_stroke,
      # @transparent_light_grey
      @really_really_transparent_light_grey
    }})
    # |> draw_circle(state, factor * Renseijin.State.inner_radius(frame, state), %{stroke: {
    #   state.primary_stroke,
    #   :grey
    # }})
    |> draw_circle(state, factor * Renseijin.State.outer_radius(frame, state), %{stroke: {
      state.primary_stroke,
      # @transparent_light_grey
      @really_really_transparent_light_grey
    }})
  end

  def draw_circle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        radius,
        %{stroke: {stroke, color}}
      )
      when is_float(radius) do
    graph
    |> Scenic.Primitives.circle(
      radius,
      stroke: {stroke, color}
    )
  end

  #############################################################################
  # Drawing squares
  # ===========================================================================

  @glyph_pf 1.72 # glyph placement factor, how much extra out we place the 4 glyhps
  @double 2

  # @transparent_light_grey :green
  def draw_greatsquares(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    factor = 1.72
    radius = Renseijin.State.radius(frame)

    # %{point: {center_x, center_y}} = c = Widgex.Frame.center(frame)


    # |> draw_circle(state, factor * Renseijin.State.radius(frame), %{stroke: {
    #   state.primary_stroke,
    #   :grey
    # }})
    # # |> draw_circle(state, factor * Renseijin.State.inner_radius(frame, state), %{stroke: {
    # #   state.primary_stroke,
    # #   :grey
    # # }})
    # |> draw_circle(state, factor * Renseijin.State.outer_radius(frame, state), %{stroke: {
    #   state.primary_stroke,
    #   :grey
    # }})

    # e = Math.exp(1)

    # integerized_c = point: {1024.5, 588.0}

    # IO.inspect(c)



    graph
    # this is the full outer frame! Why do we need the minus one?? Ask Allah!
    # |> Scenic.Primitives.rounded_rectangle(
    #       {frame.size.width-1, frame.size.height, 4},
    #       # fill: :white,
    #       stroke: {1, :dark_gray},
    #       # translate: {-@sin45*radius, -@sin45*radius}
    #       # translate: c.point
    #       translate: {-1/2*frame.size.width, -1/2*frame.size.height}
    #       # translate: frame.pin.point
    #     )
    # |> Scenic.Primitives.rounded_rectangle(
    #   {(2 * @sin45 * radius)-1, (2 * @sin45 * radius), 4},
    #   # fill: :white,
    #   stroke: {1, :dark_gray},
    #   # stroke: {1, {211, 211, 211, 0.45}},
    #   # {:rgba, 211, 211, 211, 0.45}
    #   # translate: {-@sin45*radius, -@sin45*radius}
    #   # translate: c.point
    #   # translate: {-1/2*frame.size.width, -1/2*frame.size.height}
    #   translate: {-@sin45 * radius, -@sin45 * radius}
    #   # translate: frame.pin.point
    # # )
    |> Scenic.Primitives.rounded_rectangle(
      {(@double * 2 * @sin45 * radius)-1, (@double * 2 * @sin45 * radius), 4},
      # fill: :white,
      stroke: {1, @really_really_transparent_light_grey},
      # translate: {-@sin45*radius, -@sin45*radius}
      # translate: c.point
      # translate: {-1/2*frame.size.width, -1/2*frame.size.height}
      translate: {@double * -@sin45 * radius, @double * -@sin45 * radius}
      # translate: frame.pin.point
    )
    # |> Scenic.Primitives.rounded_rectangle(
    #   {(@e * 2 * @sin45 * radius)-1, (@e * 2 * @sin45 * radius), 4},
    #   # fill: :white,
    #   stroke: {1, :light_gray},
    #   # translate: {-@sin45*radius, -@sin45*radius}
    #   # translate: c.point
    #   # translate: {-1/2*frame.size.width, -1/2*frame.size.height}
    #   translate: {@e * -@sin45 * radius, @e * -@sin45 * radius}
    #   # translate: frame.pin.point
    # )
    |> Scenic.Primitives.text(
      # Earth
      # "𓂸",
      "𓀨",
      font_size: 72,
      font: :egtyptian_heiroglyphs,
      fill: state.primary_color,
      text_align: :center,
      # translate: {-(@sin45 * radius) - 70, -(@sin45 * radius) - 50},
      translate: {@glyph_pf*(@sin45 * radius), @glyph_pf*(@sin45 * radius)},
      id: :taijitu_text,
      rotate: degree_in_radians(-45)

    )
    |> Scenic.Primitives.text(
      # Water
      # "𓈖",
      # "𓁔",
      "𓍝",
      font_size: 72,
      font: :egtyptian_heiroglyphs,
      fill: state.primary_color,
      text_align: :center,
      # translate: {(@sin45 * radius) + 70, (@sin45 * radius) + 90},
      translate: {-@glyph_pf*(@sin45 * radius), -@glyph_pf*(@sin45 * radius)},
      id: :taijitu_text,
      rotate: degree_in_radians(135)

    )

    |> Scenic.Primitives.text(
      # Fire
      # "𓃻",
      # "𓁔",
      "𓅋",
      font_size: 72,
      font: :egtyptian_heiroglyphs,
      fill: state.primary_color,
      text_align: :center,
      # translate: {(@sin45 * radius) + 70, (@sin45 * radius) + 90},
      translate: {@glyph_pf*(@sin45 * radius), -@glyph_pf*(@sin45 * radius)},
      id: :taijitu_text,
      rotate: degree_in_radians(-135)

    )
    |> Scenic.Primitives.text(
      # Air
      # "𓍝",
      # "𓁔",
      "𓅛",
      font_size: 72,
      font: :egtyptian_heiroglyphs,
      fill: state.primary_color,
      text_align: :center,
      # translate: {(@sin45 * radius) + 70, (@sin45 * radius) + 90},
      translate: {-@glyph_pf*(@sin45 * radius), @glyph_pf*(@sin45 * radius)},
      id: :taijitu_text,
      rotate: degree_in_radians(45)

    )





  end

  #############################################################################
  # Drawing triangles
  # ===========================================================================

  def draw_triangles(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    graph
    |> draw_triangle(state, equilateral: Renseijin.State.radius(frame))
    |> draw_triangle(state, equilateral: Renseijin.State.inner_radius(frame, state))
    |> draw_triangle(state, equilateral: Renseijin.State.outer_radius(frame, state))
    |> Scenic.Primitives.text(
      # Mercury - The spirit
      "☿",
      font_size: 56,
      font: :noto_sans_symbols,
      fill: state.primary_color,
      text_align: :center,
      translate: {0, -240}
    )
    |> Scenic.Primitives.text(
      # Salt - the body
      "🜔",
      font_size: 46,
      font: :noto_sans_symbols,
      fill: state.primary_color,
      text_align: :center,
      translate: {-@cos30*240, (1/2)*240},
      rotate: degree_in_radians(240)
    )
    |> Scenic.Primitives.text(
      # Sulphur - the MindSoul
      "🜍",
      font_size: 56,
      font: :noto_sans_symbols,
      fill: state.primary_color,
      text_align: :center,
      translate: {@cos30*240, (1/2)*240},
      rotate: degree_in_radians(120)
    )
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        equilateral: radius
      )
      when is_float(radius) do
    graph
    |> Scenic.Primitives.triangle(
      equilateral_triangle_coords(radius),
      stroke: {
        state.primary_stroke,
        # {:color_rgba, {r, g, b, a}}
        state.primary_color
      }
    )
  end

  # creates an "upwards pointing" equilateral triangle
  # the `radius` is the distance from the center of the triangle to any of its vertices
  def equilateral_triangle_coords(radius) do
    {
      {-1 * :math.sqrt(3) * radius / 2, radius / 2},
      {0, -1 * radius},
      {:math.sqrt(3) * radius / 2, radius / 2}
    }
  end

  #############################################################################
  # Draw Squares
  # ===========================================================================

  # def draw_squares(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
  #   graph
  #   |> draw_square(state, Renseijin.State.inner_radius(frame, state))
  # end

  # @transparent_light_grey {:color_rgba, {211, 211, 211, 50}}
  # def draw_square(
  #       %Scenic.Graph{} = graph,
  #       %Renseijin.State{} = state,
  #       radius
  #     ) do
  #   # note - the `radius` of the square is the centroid to the flat-edge, NOT the vertex
  #   graph
  #   |> Scenic.Primitives.quad(
  #     square_coords(radius)
  #     # TODO use secondary color, or get themes working properly ;)
  #     # stroke: {1, @transparent_light_grey}
  #   )
  # end

  # def square_coords(radius) do
  #   r = radius

  #   {
  #     {-r, r},
  #     {-r, -r},
  #     {r, -r},
  #     {r, r}
  #   }
  # end

  #############################################################################
  # Draw Conatus Spiral - The Essential Striving Force
  # v0.47 - Where Claude taught Luke about 'conatus' and we enhanced the renseijin
  # ===========================================================================
  
  def draw_conatus_spiral(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)
    
    # Create the conatus spiral - representing the essential striving force
    # Using phi-based growth for natural harmony
    spiral_turns = 3
    spiral_points = 120
    
    spiral_path = build_conatus_spiral_path(radius, spiral_turns, spiral_points)
    
    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)
    
    graph
    |> Scenic.Primitives.path(
      spiral_path,
      stroke: {1.5, stroke_color},
      cap: :round,
      id: :conatus_spiral
    )
  end
  
  defp build_conatus_spiral_path(base_radius, turns, num_points) do
    angle_step = @tau * turns / num_points
    
    path_elements = 
      Enum.map(0..num_points, fn i ->
        angle = i * angle_step
        # Phi-based growth for natural spiral
        radius_growth = :math.pow(@phi, angle / @tau) * 0.1
        current_radius = base_radius * 0.3 + radius_growth * base_radius * 0.2
        
        x = :math.cos(angle) * current_radius
        y = :math.sin(angle) * current_radius
        
        if i == 0 do
          {:move_to, x, y}
        else
          {:line_to, x, y}
        end
      end)
    
    [:begin] ++ path_elements
  end

  #############################################################################
  # Draw Phi Harmonics - Golden Ratio Resonance
  # ===========================================================================
  
  def draw_phi_harmonics(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state)
    
    # Create harmonic circles based on phi ratios
    base_radius = radius * 0.618  # φ^-1
    phi_radius_1 = base_radius * @phi  # φ
    phi_radius_2 = phi_radius_1 * @phi  # φ²
    
    stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)
    
    graph
    |> Scenic.Primitives.circle(base_radius,
      stroke: {0.8, {:color_rgba, {255, 215, 0, 80}}},  # Translucent gold
      id: :phi_harmonic_base
    )
    |> Scenic.Primitives.circle(phi_radius_1 * 0.618,
      stroke: {0.6, {:color_rgba, {255, 215, 0, 60}}},  # More translucent
      id: :phi_harmonic_1
    )
    |> Scenic.Primitives.circle(base_radius * 0.618,
      stroke: {0.4, {:color_rgba, {255, 215, 0, 40}}},  # Very translucent
      id: :phi_harmonic_2
    )
    # Add phi pentagon - the sacred geometry of phi
    |> draw_phi_pentagon(base_radius * @phi)
  end
  
  defp draw_phi_pentagon(%Scenic.Graph{} = graph, radius) do
    # Pentagon vertices using phi relationships
    pentagon_points = 
      Enum.map(0..4, fn i ->
        angle = i * @tau / 5 - @pi / 2  # Start at top
        x = :math.cos(angle) * radius * 0.5
        y = :math.sin(angle) * radius * 0.5
        {x, y}
      end)
    
    # Create path elements for pentagon
    [{first_x, first_y} | rest_points] = pentagon_points
    
    path_elements = 
      [{:move_to, first_x, first_y}] ++
      Enum.map(rest_points, fn {x, y} -> {:line_to, x, y} end) ++
      [:close_path]
    
    graph
    |> Scenic.Primitives.path(
      [:begin] ++ path_elements,
      stroke: {1, {:color_rgba, {255, 215, 0, 100}}},
      id: :phi_pentagon
    )
  end

  #############################################################################
  # Draw Pyramids
  # ===========================================================================

  def draw_pyramids(%Scenic.Graph{} = graph, %Widgex.Frame{} = frame, %Renseijin.State{} = state) do
    radius = Renseijin.State.inner_radius(frame, state) * (2 / 3) * (3 / 4) * (2 / 3)
    dot_radii = radius / 2

    graph
    |> draw_triangle(state, right_angle: radius + dot_radii / 3)
  end

  def draw_triangle(
        %Scenic.Graph{} = graph,
        %Renseijin.State{} = state,
        right_angle: length
      )
      when is_float(length) do
    graph
    |> Scenic.Primitives.triangle(
      right_triangle_coords(length),
      stroke: {
        state.primary_stroke,
        state.primary_color
      }
    )
  end

  def right_triangle_coords(length) do
    {
      {length, length},
      {0, length},
      {0, 0}
    }
  end



  # def draw_mask(graph, frame, state) do
  #   graph
  #   |> Scenic.Primitives.circle(
  #     State.outer_radius(frame, state),
  #     fill: :black,
  #     translate: Frame.center(frame).point
  #   )
  # end

  # @inner_color :white
  # @inner_color {:color_rgba, {255, 255, 255, 172}}
  @inner_color {:color_rgba, {250, 250, 210, 172}}
  @fade_out 500
  @fully_transparent {0, 0, 0, 0}
  def draw_mask_with_gradient(graph, frame, state) do
    # Get the center of the frame and radius
    center_point = Widgex.Frame.center(frame).point
    {center_x, center_y} = center_point
    inner_radius = Renseijin.State.inner_radius(frame, state)
    outer_radius = Renseijin.State.outer_radius(frame, state)

    # stroke_color = Enum.at(state.taijitu.rainbow, state.taijitu.color_index)

    # Define a radial gradient with proper parameters
    # gradient = {:radial, {0, 0, outer_radius, outer_radius + @fade_out, :white, :black}}
    gradient = {:radial, {0, 0, inner_radius / 3, outer_radius, @inner_color, @fully_transparent}}

    # Apply the radial gradient to the circle primitive
    graph
    |> Scenic.Primitives.circle(
      outer_radius + @fade_out,
      # outer_radius,
      # Apply the radial gradient
      fill: gradient,
      translate: center_point
      # id: :taijitu_tail
    )
  end


end




# new_graph =
#   scene.assigns.graph
#   |> Scenic.Graph.modify(
#     :inner_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: -1 * degree_in_radians(scene.assigns.rotation))
#   )
#   |> reset_mid_triangle(scene)
#   |> Scenic.Graph.modify(
#     :outer_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: -1 * degree_in_radians(scene.assigns.rotation))
#   )
#   |> Scenic.Graph.modify(
#     :taijitu,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(scene.assigns.rotation))
#   )

# def reset_mid_triangle(graph, scene) do
#   color = Scenic.Color.named(:red)

#   graph
#   |> Scenic.Graph.modify(
#     :mid_triangle,
#     &Scenic.Primitives.update_opts(&1,
#       color: color,
#       rotate: degree_in_radians(scene.assigns.rotation)
#     )
#   )
# end

# def do_animate(graph, rotation) do
#   graph
#   |> Scenic.Graph.modify(
#     :inner_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(rotation))
#   )
#   |> animate_mid_triangle(rotation)
#   |> Scenic.Graph.modify(
#     :outer_triangle,
#     &Scenic.Primitives.update_opts(&1, rotate: 2 * degree_in_radians(rotation))
#   )
#   |> Scenic.Graph.modify(
#     :taijitu,
#     &Scenic.Primitives.update_opts(&1, rotate: degree_in_radians(rotation))
#   )
# end

# def animate_mid_triangle(graph, rotation) do
#   graph
#   |> Scenic.Graph.modify(
#     :mid_triangle,
#     &Scenic.Primitives.update_opts(&1,
#       stroke: {1, :green},
#       rotate: -1 * degree_in_radians(rotation)
#     )
#   )
# end

defmodule Memelex.GUI.Components.IconButton do
  use Scenic.Component
  require Logger
  # https://ionic.io/ionicons

  @margin (50 - 32) / 2

  def validate(%{icon: _filepath} = data) do
    # TODO good validation
    {:ok, data}
  end

  def init(scene, args, opts) do
    # Logger.debug "#{__MODULE__} initializing..."

    id = opts[:id] || raise "#{__MODULE__} must receive `id` via opts."

    theme =
      (opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
      |> Scenic.Primitive.Style.Theme.normalize()

    init_graph = render(id, args, theme)

    init_scene =
      scene
      |> assign(id: id)
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      |> assign(theme: theme)
      |> assign(state: %{mode: :inactive})
      |> push_graph(init_graph)

    # Don't request global input - let events bubble up naturally
    # request_input(init_scene, [:cursor_pos, :cursor_button])

    {:ok, init_scene}
  end

  def bounds(
        %{frame: %{pin: %{x: top_left_x, y: top_left_y}, size: %{width: width, height: height}}},
        _opts
      ) do
    # NOTE: Because we use this bounds/2 function to calculate whether or
    # not the mouse is hovering over any particular button, we can't
    # translate entire groups of sub-menus around. We ned to explicitely
    # draw buttons in their correct order, and not translate them around,
    # because bounds/2 doesn't seem to work correctly with translated elements
    # TODO talk to Boyd and see if I'm wrong about this, or maybe we can improve Scenic to work with it
    left = top_left_x
    right = top_left_x + width
    top = top_left_y
    bottom = top_left_y + height
    {left, top, right, bottom}
  end

  # DEPRECATE BELOW ITS USING THE CURSED SCENIC WIDGETS FRAME
  def bounds(%{frame: %{pin: {top_left_x, top_left_y}, size: {width, height}}}, _opts) do
    # NOTE: Because we use this bounds/2 function to calculate whether or
    # not the mouse is hovering over any particular button, we can't
    # translate entire groups of sub-menus around. We ned to explicitely
    # draw buttons in their correct order, and not translate them around,
    # because bounds/2 doesn't seem to work correctly with translated elements
    # TODO talk to Boyd and see if I'm wrong about this, or maybe we can improve Scenic to work with it
    left = top_left_x
    right = top_left_x + width
    top = top_left_y
    bottom = top_left_y + height
    {left, top, right, bottom}
  end

  def render(id, args, theme) do
    #   {width, height} = args.frame.size

    # https://github.com/boydm/scenic/blob/master/lib/scenic/component/button.ex#L200
    #   vpos = height / 2 + args.font.ascent / 2 + args.font.descent / 3

    # id = opts[:id] || raise "#{__MODULE__} must receive `id` via opts."

    icon_size = {32, 32}

    translate = {@margin, @margin}

    Scenic.Graph.build()
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.rect(args.frame.size.box, id: :background, fill: :green)
        #   id: :background,
        # #   fill: if(args.hover_highlight?, do: theme.highlight, else: theme.active)
        #   fill: if(args.hover_highlight?, do: theme.highlight, else: :green)
        # )
        # graph
        # |> Scenic.Primitives.rect({32, 32}, fill: {:image, "ionicons_32_black/add.png"}, translate: {(50-32)/2, (50-32)/2})
        # |> ScenicWidgets.Ionicons.Black32.plus()
        # |> Scenic.Primitives.rect({32, 32}, fill: {:image, "ionicons/black_32/cog.png"}, translate: {@margin, @margin})
        |> Scenic.Primitives.rect(icon_size, fill: {:image, args.icon}, translate: translate)

        # |> Scenic.Primitives.text(args.label,
        #   id: :label,
        #   font: args.font.name,
        #   font_size: args.font.size,
        #   translate: {args.margin, vpos},
        #   fill: theme.text
        # )
      end,
      id: {:icon_button, id},
      translate: args.frame.pin.point,
      # Enable input events for this button
      input: [:cursor_pos, :cursor_button]
    )
  end

  def handle_input(
        {:cursor_pos, {_x, _y} = coords},
        _context,
        %{assigns: %{state: %{mode: :inactive}}} = scene
      ) do
    bounds = Scenic.Graph.bounds(scene.assigns.graph)

    if coords |> ScenicWidgets.Utils.inside?(bounds) do
      # Logger.debug "Detec'd hover: #{inspect scene.assigns.state.unique_id}, bounds: #{inspect bounds}"
      # cast_parent(scene, {:hover, scene.assigns.state.unique_id})
      new_graph =
        scene.assigns.graph
        |> Scenic.Graph.modify(
          :background,
          &Scenic.Primitives.update_opts(&1, fill: scene.assigns.theme.highlight)
        )

      new_scene =
        scene
        |> assign(graph: new_graph)
        # |> assign(frame: args.frame)
        # |> assign(theme: theme)
        |> assign(state: %{mode: :hover})
        |> push_graph(new_graph)

      {:noreply, new_scene}
    else
      # new_graph = scene.assigns.graph
      # |> Graph.modify(:background, &Scenic.Primitives.update_opts(fill: scene.assigns.theme.active))

      # new_scene =
      # scene
      # |> assign(graph: new_graph)
      # # |> assign(frame: args.frame)
      # # |> assign(theme: theme)
      # |> assign(state: %{mode: :inactive})
      # |> push_graph(new_graph)

      {:noreply, scene}
    end
  end

  def handle_input(
        {:cursor_pos, {_x, _y} = coords},
        _context,
        %{assigns: %{state: %{mode: :hover}}} = scene
      ) do
    bounds = Scenic.Graph.bounds(scene.assigns.graph)

    if coords |> ScenicWidgets.Utils.inside?(bounds) do
      {:noreply, scene}
    else
      new_graph =
        scene.assigns.graph
        #   |> Scenic.Graph.modify(:background, &Scenic.Primitives.update_opts(&1, fill: scene.assigns.theme.active))
        |> Scenic.Graph.modify(:background, &Scenic.Primitives.update_opts(&1, fill: :green))

      new_scene =
        scene
        |> assign(graph: new_graph)
        # |> assign(frame: args.frame)
        # |> assign(theme: theme)
        |> assign(state: %{mode: :inactive})
        |> push_graph(new_graph)

      {:noreply, new_scene}
    end
  end

  def handle_input({:cursor_button, {:btn_left, 0, [], click_coords}}, _context, scene) do
    bounds = Scenic.Graph.bounds(scene.assigns.graph)

    if click_coords |> ScenicWidgets.Utils.inside?(bounds) do
      cast_parent(scene, {:click, scene.assigns.id})
    end

    {:noreply, scene}
  end

  def handle_input(_input, _context, scene) do
    # Logger.debug "#{__MODULE__} ignoring input: #{inspect input}..."
    {:noreply, scene}
  end
end

defmodule Flamelex.GUI.Components.OptimizedMenuBar do
  @moduledoc """
  Optimized MenuBar component that pre-renders all dropdowns to avoid flicker.
  
  Key optimizations:
  - Pre-renders all dropdowns as hidden
  - Only toggles visibility on hover instead of re-rendering
  - Maintains comprehensive semantic DOM for all menu items
  """
  use Scenic.Component
  require Logger
  alias Flamelex.GUI.Components.MenuBar.FloatButton
  use Flamelex.GUI.Components.MenuBar.ScenicEventsDefinitions
  alias Widgex.Frame

  # Constants from original MenuBar
  @left_margin 15
  @default_font :roboto
  @default_item_width 180
  @default_top_line_font_size 36
  @default_sub_menu_height 40
  @default_sub_menu_font_size 22
  
  # Font calculations - we'll calculate ascent manually

  defstruct menu_map: nil,
            color: :grey

  # Validation
  def validate(%{frame: %Widgex.Frame{} = _f, menu_map: _menu_map} = init_data) do
    {:ok, init_data}
  end

  def init(scene, args, _opts) do
    init_state = %{
      mode: :inactive,
      font: calc_font_data(args),
      menu_map: args.menu_map,
      original_menu_map: args.menu_map,
      sub_menu: calc_sub_menu_opts(args),
      item_width: args[:item_width] || {:fixed, @default_item_width},
      color: args[:color] || :grey
    }

    init_graph = render_complete_menu(init_state, args.frame)

    init_scene =
      scene
      |> assign(state: init_state)
      |> assign(frame: args.frame)
      |> assign(graph: init_graph)
      |> push_graph(init_graph)

    # Request input events needed for hover detection
    request_input(init_scene, [:cursor_pos, :key])
    
    {:ok, init_scene}
  end

  # Handle hover - only update visibility
  def handle_cast({:hover, hover_index} = new_mode, scene) do
    old_mode = scene.assigns.state.mode
    
    if old_mode == new_mode do
      {:noreply, scene}
    else
      new_state = %{scene.assigns.state | mode: new_mode}
      new_graph = update_menu_visibility(scene.assigns.graph, old_mode, new_mode)

      new_scene =
        scene
        |> assign(state: new_state)
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

      {:noreply, new_scene}
    end
  end

  def handle_cast({:cancel, _}, scene) do
    new_state = %{scene.assigns.state | mode: :inactive}
    new_graph = update_menu_visibility(scene.assigns.graph, scene.assigns.state.mode, :inactive)

    new_scene =
      scene
      |> assign(state: new_state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def handle_cast({:click, click_path}, scene) when length(click_path) > 1 do
    [top_index | rest] = click_path
    {:sub_menu, _label, sub_menu} = Enum.at(scene.assigns.state.menu_map, top_index - 1)
    
    item = get_menu_item_at_path(sub_menu, rest)
    
    case item do
      {_label, action} when is_function(action) ->
        action.()
        GenServer.cast(self(), {:cancel, nil})
      _ ->
        :ok
    end
    
    {:noreply, scene}
  end

  def handle_cast({:click, _}, scene), do: {:noreply, scene}
  
  # Handle cursor position to detect when mouse leaves menubar area
  def handle_input({:cursor_pos, {_x, y}}, _context, scene) do
    {_x, _y, _viewport_width, menu_bar_max_height} = Scenic.Graph.bounds(scene.assigns.graph)
    
    if y > menu_bar_max_height do
      GenServer.cast(self(), {:cancel, scene.assigns.state.mode})
      {:noreply, scene}
    else
      {:noreply, scene}
    end
  end
  
  # Handle escape key
  def handle_input({:key, {:key_esc, 1, _}}, _context, scene) do
    GenServer.cast(self(), {:cancel, scene.assigns.state.mode})
    {:noreply, scene}
  end
  
  def handle_input({:key, {_key, _action, _mods}}, _context, scene) do
    # Ignore other keys
    {:noreply, scene}
  end

  # Pre-render complete menu structure
  defp render_complete_menu(state, frame) do
    Scenic.Graph.build()
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> render_background(state, frame)
        |> render_semantic_tree(state.menu_map)
        |> render_menu_bar(state, frame)
        |> render_all_dropdowns(state, frame)
      end,
      id: :optimized_menu_bar
    )
  end

  defp render_background(graph, %{color: color}, frame) when not is_nil(color) do
    graph
    |> Scenic.Primitives.rect(
      frame.size.box,
      fill: color,
      opacity: 0.5,
      id: :menu_background
    )
  end
  
  defp render_background(graph, _state, _frame) do
    # No background if color is nil
    graph
  end

  defp render_semantic_tree(graph, menu_map) do
    # Add semantic markers for all menu items
    Enum.reduce(menu_map, graph, fn menu_item, acc_graph ->
      add_semantic_menu_item(acc_graph, menu_item, [])
    end)
  end

  defp add_semantic_menu_item(graph, {:sub_menu, label, items}, path) do
    # Add semantic marker for this menu
    graph = Scenic.Primitives.text(graph, "",
      id: {:semantic_menu, path ++ [label]},
      semantic: %{
        type: :menu_item,
        label: label,
        path: path ++ [label],
        has_submenu: true
      },
      hidden: true
    )
    
    # Recursively add sub-items
    Enum.reduce(items, graph, fn item, acc ->
      add_semantic_menu_item(acc, item, path ++ [label])
    end)
  end

  defp add_semantic_menu_item(graph, {label, _action}, path) do
    Scenic.Primitives.text(graph, "",
      id: {:semantic_menu, path ++ [label]},
      semantic: %{
        type: :menu_item,
        label: label,
        path: path ++ [label],
        has_submenu: false
      },
      hidden: true
    )
  end

  defp render_menu_bar(graph, state, frame) do
    menu_items = Enum.with_index(state.menu_map, 1)
    {:fixed, item_width} = state.item_width
    
    Enum.reduce(menu_items, graph, fn {{:sub_menu, label, _}, index}, acc ->
      # Check if this menu item is being hovered
      do_hover_highlight? = case state.mode do
        :inactive -> false
        {:hover, [x]} -> x == index
        {:hover, [x | _]} -> x == index
      end
      
      acc
      |> FloatButton.add_to_graph(%{
        label: label,
        unique_id: [index],
        font: state.font,
        frame: %{
          pin: {(index - 1) * (item_width + @left_margin), 0},
          size: {item_width + @left_margin, frame.size.height}
        },
        margin: @left_margin,
        hover_highlight?: do_hover_highlight?,
        menu_map: state.original_menu_map
      })
    end)
  end

  defp render_all_dropdowns(graph, state, frame) do
    # Pre-render all dropdowns as hidden
    {:fixed, item_width} = state.item_width
    
    Enum.reduce(Enum.with_index(state.menu_map, 1), graph, fn {{:sub_menu, _, items}, index}, acc ->
      render_dropdown(acc, items, index, state, frame, item_width)
    end)
  end

  defp render_dropdown(graph, items, parent_index, state, frame, item_width) do
    x_pos = @left_margin + ((parent_index - 1) * item_width)
    y_pos = frame.size.height
    
    dropdown_height = length(items) * state.sub_menu.height
    
    graph
    |> Scenic.Primitives.group(
      fn g ->
        g
        # Dropdown background
        |> Scenic.Primitives.rect(
          {item_width, dropdown_height},
          fill: :white,
          stroke: {1, :grey},
          id: {:dropdown_bg, parent_index}
        )
        # Render each item
        |> render_dropdown_items(items, parent_index, state, item_width)
      end,
      id: {:dropdown, parent_index},
      translate: {x_pos, y_pos},
      hidden: true  # Initially hidden
    )
  end

  defp render_dropdown_items(graph, items, parent_index, state, item_width) do
    Enum.reduce(Enum.with_index(items, 1), graph, fn {item, item_index}, acc ->
      y_pos = (item_index - 1) * state.sub_menu.height
      
      case item do
        {label, _action} ->
          acc
          |> Scenic.Primitives.rect(
            {item_width - 2, state.sub_menu.height - 2},
            id: {:dropdown_item_hover, parent_index, item_index},
            fill: :light_grey,
            translate: {1, y_pos + 1},
            hidden: true
          )
          |> Scenic.Primitives.text(
            label,
            font: state.font.name,
            font_size: state.sub_menu.font_size,
            fill: :black,
            translate: {10, y_pos + state.sub_menu.font_size}
          )
          
        {:sub_menu, label, _sub_items} ->
          acc
          |> Scenic.Primitives.text(
            label <> " ►",
            font: state.font.name,
            font_size: state.sub_menu.font_size,
            fill: :black,
            translate: {10, y_pos + state.sub_menu.font_size}
          )
      end
    end)
  end

  # Update only visibility, no re-rendering
  defp update_menu_visibility(graph, old_mode, new_mode) do
    graph
    |> hide_old_hover(old_mode)
    |> show_new_hover(new_mode)
  end

  defp hide_old_hover(graph, :inactive), do: graph
  defp hide_old_hover(graph, {:hover, [index]}) do
    graph
    |> Scenic.Graph.modify({:menu_highlight, index}, &update_hidden(&1, true))
    |> Scenic.Graph.modify({:dropdown, index}, &update_hidden(&1, true))
  end
  defp hide_old_hover(graph, {:hover, [parent | rest]}) do
    graph
    |> hide_old_hover({:hover, [parent]})
    |> hide_dropdown_item_hover(parent, rest)
  end

  defp show_new_hover(graph, :inactive), do: graph
  defp show_new_hover(graph, {:hover, [index]}) do
    graph
    |> Scenic.Graph.modify({:menu_highlight, index}, &update_hidden(&1, false))
    |> Scenic.Graph.modify({:dropdown, index}, &update_hidden(&1, false))
  end
  defp show_new_hover(graph, {:hover, [parent | rest]}) do
    graph
    |> show_new_hover({:hover, [parent]})
    |> show_dropdown_item_hover(parent, rest)
  end

  defp hide_dropdown_item_hover(graph, _parent, []), do: graph
  defp hide_dropdown_item_hover(graph, parent, [index | _]) do
    Scenic.Graph.modify(graph, {:dropdown_item_hover, parent, index}, &update_hidden(&1, true))
  end

  defp show_dropdown_item_hover(graph, _parent, []), do: graph
  defp show_dropdown_item_hover(graph, parent, [index | _]) do
    Scenic.Graph.modify(graph, {:dropdown_item_hover, parent, index}, &update_hidden(&1, false))
  end

  defp update_hidden(primitive, hidden) do
    Scenic.Primitives.update_opts(primitive, hidden: hidden)
  end

  # Helper functions
  defp calc_font_data(%{font: font}) when is_map(font), do: font
  defp calc_font_data(_) do
    {:ok, {_, metrics}} = Scenic.Assets.Static.meta(@default_font)
    %{
      name: @default_font,
      metrics: metrics,
      size: @default_top_line_font_size,
      ascent: calculate_ascent(@default_top_line_font_size)
    }
  end
  
  # Calculate ascent as approximately 80% of font size
  # This is a reasonable approximation for most fonts
  defp calculate_ascent(font_size) do
    round(font_size * 0.8)
  end

  defp calc_sub_menu_opts(%{sub_menu: opts}) when is_map(opts), do: opts
  defp calc_sub_menu_opts(_) do
    %{
      height: @default_sub_menu_height,
      font_size: @default_sub_menu_font_size
    }
  end

  defp get_menu_item_at_path(menu, [index]) do
    Enum.at(menu, index - 1)
  end
  defp get_menu_item_at_path(menu, [index | rest]) do
    case Enum.at(menu, index - 1) do
      {:sub_menu, _, sub_items} -> get_menu_item_at_path(sub_items, rest)
      item -> item
    end
  end

  # Standard Scenic component add_to_graph function
  def add_to_graph(graph, data) do
    Scenic.Components.add_to_graph(graph, __MODULE__, data)
  end
end
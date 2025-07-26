defmodule Flamelex.GUI.Components.MenuBar.EnhancedMenuBar do
  @moduledoc """
  EnhancedMenuBar - A robust, configurable dropdown menu bar component.
  
  This is an enhanced version of MenuBar with additional features:
  - Event propagation fixes (no more click-through)
  - Multiple visual themes and styles  
  - Configurable interaction modes (hover vs click)
  - Flexible layout and alignment options
  - Text clipping and button width controls
  - Comprehensive styling options
  
  ## Usage
  
      # Basic usage with defaults
      graph |> Flamelex.GUI.Components.MenuBar.EnhancedMenuBar.add_to_graph(%{
        menu_map: menu_map(),
        frame: frame
      })
      
      # Advanced configuration
      data = %{
        menu_map: menu_map(),
        theme: :modern,
        interaction_mode: :click, # or :hover (default)
        button_width: {:auto, :min_width, 120},
        text_clipping: :ellipsis,
        dropdown_alignment: :wide_centered,
        colors: %{
          background: {30, 30, 30},
          text: {240, 240, 240}
        }
      }
      
      graph |> Flamelex.GUI.Components.MenuBar.EnhancedMenuBar.add_to_graph(data, frame: frame)
  """
  
  use Scenic.Component
  require Logger
  use Flamelex.GUI.Components.MenuBar.ScenicEventsDefinitions
  alias Flamelex.GUI.Components.MenuBar.FloatButton
  # alias Widgex.Frame

  @impl Scenic.Component
  def validate(data) when is_map(data) do
    # Validate required fields
    unless Map.has_key?(data, :menu_map) do
      raise ArgumentError, "menu_map is required"
    end
    
    unless Map.has_key?(data, :frame) do
      raise ArgumentError, "frame is required"
    end
    
    # Normalize and apply defaults
    normalized = %{
      # Required fields
      menu_map: data.menu_map,
      frame: data.frame,
      
      # Interaction behavior
      interaction_mode: Map.get(data, :interaction_mode, :hover), # :hover | :click
      hover_delay: Map.get(data, :hover_delay, 0), # ms before hover opens dropdown
      auto_close_delay: Map.get(data, :auto_close_delay, 2000), # auto-close after inactivity
      
      # Layout and sizing  
      button_width: Map.get(data, :button_width, {:auto, :min_width, 120}), # {:auto, :min_width, 120} | {:fixed, 180}
      button_height: Map.get(data, :button_height, 40),
      text_alignment: Map.get(data, :text_alignment, :left), # :left | :center | :right
      text_clipping: Map.get(data, :text_clipping, :ellipsis), # :ellipsis | :truncate | :none
      
      # Dropdown positioning
      dropdown_alignment: Map.get(data, :dropdown_alignment, :wide_centered), # :button_left | :button_center | :button_right | :wide_centered
      dropdown_width_mode: Map.get(data, :dropdown_width_mode, :wide_offset), # :match_button | :auto_fit | :wide_offset
      dropdown_offset: Map.get(data, :dropdown_offset, %{x: 0, y: 0}), # Fine-tune positioning
      
      # Visual theme
      theme: Map.get(data, :theme, :default), # :default | :minimal | :modern | :retro
      
      # Typography
      font: Map.get(data, :font, %{name: :roboto, size: 16}),
      dropdown_font: Map.get(data, :dropdown_font, %{name: :roboto, size: 14}),
      
      # Event handling
      consume_events: Map.get(data, :consume_events, true), # Fix the propagation bug
      keyboard_navigation: Map.get(data, :keyboard_navigation, true),
      
      # Spacing and margins
      button_spacing: Map.get(data, :button_spacing, 2),
      dropdown_margin: Map.get(data, :dropdown_margin, 4),
      text_margin: Map.get(data, :text_margin, 8)
    }
    
    # Apply theme colors, allow overrides
    theme_colors = get_theme_colors(normalized.theme)
    final_colors = Map.merge(theme_colors, Map.get(data, :colors, %{}))
    
    final_normalized = Map.put(normalized, :colors, final_colors)
    
    {:ok, final_normalized}
  end

  # Theme color definitions - similar to Ubuntu bar approach
  def get_theme_colors(:default) do
    %{
      background: {40, 40, 40},
      button: {55, 55, 55}, 
      button_hover: {75, 75, 75},
      button_active: {85, 130, 180},
      text: {240, 240, 240},
      border: {100, 100, 100},
      dropdown_bg: {45, 45, 45}
    }
  end
  
  def get_theme_colors(:minimal) do
    %{
      background: {250, 250, 250},
      button: {245, 245, 245},
      button_hover: {235, 235, 235},
      button_active: {220, 220, 220},
      text: {60, 60, 60},
      border: {200, 200, 200},
      dropdown_bg: {255, 255, 255}
    }
  end
  
  def get_theme_colors(:modern) do
    %{
      background: {25, 25, 30},
      button: {35, 35, 40},
      button_hover: {50, 50, 60},
      button_active: {70, 130, 200},
      text: {230, 230, 235},
      border: {65, 65, 75},
      dropdown_bg: {30, 30, 35}
    }
  end
  
  def get_theme_colors(:retro) do
    %{
      background: {20, 80, 20},
      button: {30, 100, 30},
      button_hover: {40, 120, 40},
      button_active: {60, 180, 60},
      text: {200, 255, 200},
      border: {100, 200, 100},
      dropdown_bg: {25, 90, 25}
    }
  end
  
  def get_theme_colors(theme) when is_atom(theme) do
    Logger.warning("Unknown theme #{inspect(theme)}, falling back to :default")
    get_theme_colors(:default)
  end

  @impl Scenic.Scene
  def init(scene, data, opts) do
    theme = 
      (opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
      |> Scenic.Primitive.Style.Theme.normalize()

    init_state = %{
      mode: :inactive,
      data: data,
      hover_timer: nil
    }

    init_graph = render(%{
      state: init_state,
      theme: theme
    })

    init_scene =
      scene
      |> assign(state: init_state) 
      |> assign(graph: init_graph)
      |> assign(theme: theme)
      |> push_graph(init_graph)

    # Request key events and cursor_pos for menu bounds checking
    request_input(init_scene, [:cursor_pos, :key])

    {:ok, init_scene}
  end

  def render(%{state: state, theme: theme}) do
    data = state.data
    
    Scenic.Graph.build()
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> render_main_menu_bar(data, theme, state)
        |> render_dropdowns(data, theme, state)
      end,
      id: :enhanced_menu_bar
    )
  end

  defp render_main_menu_bar(graph, data, theme, state) do
    frame = data.frame
    
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.rect({frame.size.width, frame.size.height}, fill: data.colors.background, id: :menu_background)
        |> render_menu_buttons(data, theme, state)
      end,
      id: :main_menu_bar
    )
  end

  defp render_menu_buttons(graph, data, theme, state) do
    # Extract top-level menu labels
    menu_items = 
      data.menu_map
      |> Enum.map(fn
        {:sub_menu, label, _sub_menu} -> label
      end)
      |> Enum.with_index(1)

    IO.puts("🔍 EnhancedMenuBar: Found #{length(menu_items)} menu items")
    IO.puts("   Menu items: #{inspect(menu_items)}")
    IO.puts("   Current mode: #{inspect(state.mode)}")

    graph
    |> do_render_menu_buttons(data, theme, state, menu_items)
  end

  defp do_render_menu_buttons(graph, _data, _theme, _state, []) do
    graph
  end

  defp do_render_menu_buttons(graph, data, theme, state, [{label, index} | rest]) do
    button_width = calculate_button_width(data, label)
    
    # Apply text clipping if needed
    font_data = calculate_font_data(data.font)
    available_text_width = button_width - (data.text_margin * 2)
    clipped_label = clip_text_to_width(label, available_text_width, font_data, data.text_clipping)
    
    # DEBUG: Log what we're trying to render
    IO.puts("🔍 EnhancedMenuBar: Rendering button #{index}")
    IO.puts("   Label: '#{label}' -> '#{clipped_label}'")
    IO.puts("   Button width: #{button_width}, Frame height: #{data.frame.size.height}")
    IO.puts("   Font: #{inspect(data.font)}")
    IO.puts("   Position: {#{(index - 1) * (button_width + data.button_spacing)}, 0}")
    
    # Determine if this button should be highlighted
    highlight? = case state.mode do
      :inactive -> false
      {:hover, [hover_index]} when hover_index == index -> true
      {:hover, [hover_index | _]} when hover_index == index -> true
      _ -> false
    end

    IO.puts("   Highlight: #{highlight?}")

    # Create a complete theme that includes all required Scenic theme fields
    float_button_theme = %{
      active: data.colors.button || data.colors.background,
      highlight: data.colors.button_hover || data.colors.button_active,
      text: data.colors.text,
      background: data.colors.background,
      border: data.colors.border || data.colors.text,
      thumb: data.colors.button_hover || data.colors.button_active,
      focus: data.colors.button_active || data.colors.button_hover
    }
    
    graph
    |> FloatButton.add_to_graph(%{
      label: clipped_label,
      unique_id: [index],
      font: font_data,
      frame: %{
        pin: {(index - 1) * (button_width + data.button_spacing), 0},
        size: {button_width, data.frame.size.height}
      },
      margin: data.text_margin,
      hover_highlight?: highlight?
    }, theme: float_button_theme)
    |> do_render_menu_buttons(data, theme, state, rest)
  end

  defp render_dropdowns(graph, data, theme, state) do
    case state.mode do
      :inactive -> graph
      {:hover, hover_chain} -> 
        dropdowns = calculate_dropdowns(data, hover_chain)
        render_dropdown_list(graph, data, theme, dropdowns)
    end
  end

  defp render_dropdown_list(graph, _data, _theme, []) do
    graph
  end

  defp render_dropdown_list(graph, data, theme, [dropdown | rest]) do
    graph
    |> render_single_dropdown(data, theme, dropdown)
    |> render_dropdown_list(data, theme, rest)
  end

  defp render_single_dropdown(graph, data, theme, {menu_id, offsets, items}) do
    if items == [] do
      graph
    else
      # Calculate dropdown dimensions
    num_items = Enum.count(items)
    [top_hover_index | _] = menu_id
    dropdown_width = calculate_dropdown_width(data, items)
    dropdown_height = num_items * data.frame.size.height
    
    # Calculate position based on alignment settings
    {dropdown_x, dropdown_y} = calculate_dropdown_position(data, menu_id, offsets, dropdown_width)
    
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        # Render background
        graph
        |> Scenic.Primitives.rect({dropdown_width, dropdown_height},
          fill: data.colors.dropdown_bg || data.colors.background,
          stroke: {1, data.colors.border || data.colors.text},
          id: {:dropdown_bg, menu_id}
        )
        # Render menu items
        |> render_dropdown_items(data, theme, items, menu_id, dropdown_width)
        # Draw top line mask to blend with menu bar
        |> draw_top_line_mask(data, dropdown_width, top_hover_index)
      end,
      translate: {dropdown_x, dropdown_y},
      id: {:dropdown, menu_id}
    )
    end
  end
  
  defp render_dropdown_items(graph, data, theme, items, menu_id, dropdown_width) do
    items
    |> Enum.with_index(1)
    |> Enum.reduce(graph, fn {item, index}, acc_graph ->
      render_dropdown_item(acc_graph, data, theme, item, menu_id ++ [index], index - 1, dropdown_width)
    end)
  end
  
  defp render_dropdown_item(graph, data, _theme, item, item_id, y_index, dropdown_width) do
    {label, has_submenu} = case item do
      {label, _func} -> {label, false}
      {:sub_menu, label, _items} -> {label, true}
    end
    
    # For now, no highlighting on dropdown items (could be added later)
    highlight? = false
    
    item_y = y_index * data.frame.size.height
    
    # Create complete theme for dropdown items
    dropdown_theme = %{
      active: data.colors.dropdown_bg || data.colors.background,
      highlight: data.colors.button_hover || data.colors.button_active,
      text: data.colors.text,
      background: data.colors.dropdown_bg || data.colors.background,
      border: data.colors.border || data.colors.text,
      thumb: data.colors.button_hover || data.colors.button_active,
      focus: data.colors.button_active || data.colors.button_hover
    }
    
    graph
    |> FloatButton.add_to_graph(%{
      label: label,
      unique_id: item_id,
      font: calculate_font_data(data.dropdown_font || data.font),
      frame: %{
        pin: {0, item_y},
        size: {dropdown_width, data.frame.size.height}
      },
      margin: data.text_margin,
      hover_highlight?: highlight?,
      draw_sub_menu_triangle?: has_submenu
    }, theme: dropdown_theme)
  end
  
  defp calculate_dropdown_width(data, items) do
    case data.dropdown_width_mode do
      :match_button -> 
        calculate_button_width(data, "")
      :auto_fit ->
        # Calculate based on longest item text
        max_text_width = items
        |> Enum.map(fn
          {label, _} -> String.length(label)
          {:sub_menu, label, _} -> String.length(label)
        end)
        |> Enum.max(fn -> 0 end)
        max_text_width * 8 + data.text_margin * 2  # Rough character width estimation
      :wide_offset ->
        button_width = calculate_button_width(data, "")
        button_width + 20  # Add some extra width
    end
  end
  
  defp calculate_dropdown_position(data, menu_id, offsets, dropdown_width) do
    [top_hover_index | _] = menu_id
    button_width = calculate_button_width(data, "")
    
    base_x = (top_hover_index - 1) * (button_width + data.button_spacing)
    base_y = data.frame.size.height
    
    # Apply alignment
    aligned_x = case data.dropdown_alignment do
      :button_left -> base_x
      :button_center -> base_x + (button_width - dropdown_width) / 2
      :button_right -> base_x + button_width - dropdown_width
      :wide_centered -> base_x - (dropdown_width - button_width) / 2
    end
    
    # Apply offsets for nested menus
    final_x = aligned_x + offsets.x * dropdown_width + data.dropdown_offset.x
    final_y = base_y + offsets.y * data.frame.size.height + data.dropdown_offset.y
    
    {final_x, final_y}
  end
  
  defp draw_top_line_mask(graph, data, dropdown_width, top_hover_index) do
    # Draw a line over the top border to blend with menu bar
    button_width = calculate_button_width(data, "")
    line_start_x = if top_hover_index == 1, do: 0, else: -2
    line_end_x = dropdown_width + 2
    
    graph
    |> Scenic.Primitives.line(
      {{line_start_x, 0}, {line_end_x, 0}},
      stroke: {2, data.colors.background},
      translate: {(top_hover_index - 1) * button_width, 0}
    )
  end

  # Helper functions for layout calculations
  defp calculate_button_width(data, label) do
    case data.button_width do
      {:fixed, width} -> width
      {:auto, :min_width, min_width} ->
        # Calculate based on actual text width using font metrics
        font_data = calculate_font_data(data.font)
        text_width = FontMetrics.width(label, font_data.size, font_data.metrics)
        # Add margin for padding and ensure minimum width
        calculated_width = text_width + data.text_margin * 2
        max(min_width, calculated_width)
    end
  end
  
  defp clip_text_to_width(text, max_width, font_data, clipping_mode) do
    current_width = FontMetrics.width(text, font_data.size, font_data.metrics)
    
    if current_width <= max_width do
      text
    else
      case clipping_mode do
        :none -> text
        :truncate -> 
          # Simple truncation - keep removing characters until it fits
          truncate_text_to_width(text, max_width, font_data)
        :ellipsis ->
          # Add ellipsis and ensure total width fits
          ellipsis_width = FontMetrics.width("…", font_data.size, font_data.metrics)
          available_width = max_width - ellipsis_width
          if available_width > 0 do
            truncated = truncate_text_to_width(text, available_width, font_data)
            truncated <> "…"
          else
            "…"
          end
      end
    end
  end
  
  defp truncate_text_to_width(text, max_width, font_data) do
    if String.length(text) <= 1 do
      ""
    else
      # Try removing one character at a time from the end
      shorter_text = String.slice(text, 0, String.length(text) - 1)
      current_width = FontMetrics.width(shorter_text, font_data.size, font_data.metrics)
      
      if current_width <= max_width do
        shorter_text
      else
        truncate_text_to_width(shorter_text, max_width, font_data)
      end
    end
  end

  # Cache to avoid reloading fonts on every render
  @font_cache_key :enhanced_menu_bar_font_cache
  
  defp calculate_font_data(%{name: name, size: size}) do
    cache_key = {name, size}
    
    case Process.get(@font_cache_key) do
      %{^cache_key => cached_font_data} ->
        # Font already cached, return it
        cached_font_data
        
      cache_map when is_map(cache_map) ->
        # Cache exists but this font not in it, load and cache
        load_and_cache_font(cache_key, name, size, cache_map)
        
      _ ->
        # No cache yet, create it and load font
        load_and_cache_font(cache_key, name, size, %{})
    end
  end
  
  defp load_and_cache_font({name, size} = cache_key, name, size, cache_map) do
    case Scenic.Assets.Static.meta(name) do
      {:ok, {_type, metrics}} ->
        font_data = %{
          name: name,
          size: size,
          ascent: FontMetrics.ascent(size, metrics),
          descent: FontMetrics.descent(size, metrics),
          metrics: metrics
        }
        # Cache the font data
        new_cache = Map.put(cache_map, cache_key, font_data)
        Process.put(@font_cache_key, new_cache)
        font_data
        
      {:error, _reason} ->
        # Fallback to a default font
        {:ok, {_type, default_metrics}} = Scenic.Assets.Static.meta(:roboto_mono)
        font_data = %{
          name: :roboto_mono,
          size: size,
          ascent: FontMetrics.ascent(size, default_metrics),
          descent: FontMetrics.descent(size, default_metrics),
          metrics: default_metrics
        }
        # Cache the fallback font data
        new_cache = Map.put(cache_map, cache_key, font_data)
        Process.put(@font_cache_key, new_cache)
        font_data
    end
  end

  defp calculate_dropdowns(data, hover_chain) do
    case hover_chain do
      [] -> []
      [top_hover_index] ->
        # Single level dropdown
        {:sub_menu, _label, top_lvl_sub_menu} = data.menu_map |> Enum.at(top_hover_index - 1)
        [{[top_hover_index], %{x: 0, y: 0}, top_lvl_sub_menu}]
      
      [top_hover_index | _rest] ->
        # Multi-level dropdown chain
        depth = Enum.count(hover_chain)
        # Get the first menu
        first_menu = calculate_dropdowns(data, [top_hover_index]) |> List.first()
        # Calculate nested menus
        do_calculate_dropdowns(data, [first_menu], hover_chain, {1, depth, 0})
    end
  end
  
  defp do_calculate_dropdowns(_data, sub_menu_list, _hover_chain, {count, depth, _y_offset})
       when count >= depth do
    sub_menu_list
  end
  
  defp do_calculate_dropdowns(data, sub_menu_list, hover_chain, {count, depth, y_offset_carry}) do
    sub_menu_id = Enum.take(hover_chain, count + 1)
    
    case fetch_item_at(data.menu_map, sub_menu_id) do
      {:ok, {_label, _func}, this_y_offset} ->
        # Leaf item, no new dropdown
        new_y_offset = y_offset_carry + this_y_offset
        do_calculate_dropdowns(data, sub_menu_list, hover_chain, {count + 1, depth, new_y_offset})
        
      {:ok, {:sub_menu, _label, new_sub_menu}, this_y_offset} ->
        # Sub-menu, add new dropdown
        new_y_offset = y_offset_carry + this_y_offset
        next_menu = {sub_menu_id, %{x: count, y: new_y_offset}, new_sub_menu}
        do_calculate_dropdowns(data, sub_menu_list ++ [next_menu], hover_chain, {count + 1, depth, new_y_offset})
        
      _ ->
        # Error case, stop recursion
        sub_menu_list
    end
  end
  
  defp fetch_item_at(menu_map, [x]) when is_integer(x) do
    case Enum.at(menu_map, x - 1) do
      nil -> {:error, :not_found}
      item -> {:ok, item, x - 1}
    end
  end
  
  defp fetch_item_at(menu_map, [x | rest]) when is_integer(x) do
    case Enum.at(menu_map, x - 1) do
      {:sub_menu, _label, sub_menu} ->
        fetch_item_at(sub_menu, rest)
      _ ->
        {:error, :not_submenu}
    end
  end

  # Event handling with proper consumption
  def handle_input({:cursor_pos, {_x, y}}, _context, scene) do
    # Only process cursor position for closing menus, like the original MenuBar
    case scene.assigns.state.mode do
      :inactive -> 
        {:noreply, scene}
      {:hover, _} ->
        # Check if cursor moved outside menu bounds
        {_x, _y, _width, menu_height} = Scenic.Graph.bounds(scene.assigns.graph)
        
        if y > menu_height do
          # Cursor outside menu area, close dropdowns
          current_mode = scene.assigns.state.mode
          new_state = %{scene.assigns.state | mode: :inactive}
          updated_graph = update_menu_graph(scene.assigns.graph, current_mode, :inactive, new_state, scene.assigns.theme)
          
          new_scene = scene
          |> assign(state: new_state)
          |> assign(graph: updated_graph)
          |> push_graph(updated_graph)
          
          {:noreply, new_scene}
        else
          # Cursor still in menu area, event consumed by handling
          {:noreply, scene}
        end
    end
  end

  def handle_input({:cursor_button, {:btn_left, 0, [], _coords}}, _context, scene) do
    data = scene.assigns.state.data
    
    # Only handle clicks if we're in click mode
    case data.interaction_mode do
      :click ->
        # In click mode, trigger hover behavior on click
        # Note: This would need more sophisticated logic to determine which menu item was clicked
        # For now, just consume the event
        {:noreply, scene}
      :hover ->
        # In hover mode, clicks outside should close menus
        case scene.assigns.state.mode do
          :inactive -> {:noreply, scene}
          {:hover, _} ->
            new_state = %{scene.assigns.state | mode: :inactive}
            new_graph = render(%{state: new_state, theme: scene.assigns.theme})
            
            new_scene = scene
            |> assign(state: new_state)
            |> assign(graph: new_graph)
            |> push_graph(new_graph)
            
            {:noreply, new_scene}
        end
    end
  end

  def handle_input(@escape_key, _context, scene) do
    new_state = %{scene.assigns.state | mode: :inactive}
    new_graph = render(%{state: new_state, theme: scene.assigns.theme})
    
    new_scene = 
      scene
      |> assign(state: new_state)
      |> assign(graph: new_graph) 
      |> push_graph(new_graph)
      
    # Escape key event consumed by handling
    {:noreply, new_scene}
  end

  def handle_input(_input, _context, scene) do
    {:noreply, scene}
  end

  # Cast handlers for mode changes
  @impl GenServer
  def handle_cast({:hover, hover_index}, scene) do
    current_mode = scene.assigns.state.mode
    new_mode = {:hover, hover_index}
    
    # More precise state comparison to avoid unnecessary updates
    mode_changed = case {current_mode, new_mode} do
      {:inactive, {:hover, _}} -> true
      {{:hover, old_index}, {:hover, new_index}} when old_index != new_index -> true
      _ -> false
    end
    
    if mode_changed do
      IO.puts("🎯 EnhancedMenuBar: Mode change detected: #{inspect(current_mode)} -> #{inspect(new_mode)}")
      new_state = %{scene.assigns.state | mode: new_mode}
      updated_graph = update_menu_graph(scene.assigns.graph, current_mode, new_mode, new_state, scene.assigns.theme)
      
      new_scene =
        scene
        |> assign(state: new_state)
        |> assign(graph: updated_graph)
        |> push_graph(updated_graph)
        
      {:noreply, new_scene}
    else
      # Same hover state, no update needed
      {:noreply, scene}
    end
  end

  def handle_cast({:click, click_coords}, scene) do
    IO.puts("🖱️ EnhancedMenuBar: Received click event: #{inspect(click_coords)}")
    data = scene.assigns.state.data
    
    case click_coords do
      [_top_index] ->
        # Click on top-level menu item, just ignore
        {:noreply, scene}
        
      [top_index | rest_coords] ->
        # Click on dropdown item
        {:sub_menu, _label, sub_menu} = data.menu_map |> Enum.at(top_index - 1)
        
        case fetch_item_at(sub_menu, rest_coords) do
          {:ok, {_label, action}, _offset} when is_function(action) ->
            # Execute the action
            action.()
            # Close the menu
            new_state = %{scene.assigns.state | mode: :inactive}
            new_graph = render(%{state: new_state, theme: scene.assigns.theme})
            
            new_scene = scene
            |> assign(state: new_state)
            |> assign(graph: new_graph)
            |> push_graph(new_graph)
            
            {:noreply, new_scene}
            
          {:ok, {:sub_menu, _label, _items}, _offset} ->
            # Click on sub-menu, do nothing (just show the sub-menu)
            {:noreply, scene}
            
          _ ->
            # Invalid click, ignore
            {:noreply, scene}
        end
    end
  end

  def handle_cast({:cancel, mode}, scene) do
    IO.puts("❌ EnhancedMenuBar: Received cancel event for mode: #{inspect(mode)}")
    # Only cancel if we're not already inactive
    case scene.assigns.state.mode do
      :inactive ->
        # Already inactive, no need to update
        {:noreply, scene}
      current_mode ->
        # Close the menu by updating to inactive
        new_state = %{scene.assigns.state | mode: :inactive}
        updated_graph = update_menu_graph(scene.assigns.graph, current_mode, :inactive, new_state, scene.assigns.theme)
        
        new_scene =
          scene  
          |> assign(state: new_state)
          |> assign(graph: updated_graph)
          |> push_graph(updated_graph)
          
        {:noreply, new_scene}
    end
  end

  def handle_cast({:put_menu_map, new_menu_map}, scene) do
    new_data = %{scene.assigns.state.data | menu_map: new_menu_map}
    new_state = %{scene.assigns.state | data: new_data, mode: :inactive}
    # Menu map change requires full re-render since structure changed
    new_graph = render(%{state: new_state, theme: scene.assigns.theme})
    
    new_scene =
      scene
      |> assign(state: new_state)
      |> assign(graph: new_graph)
      |> push_graph(new_graph)
      
    {:noreply, new_scene}
  end
  
  # ============================================================================
  # Smart Graph Updates - Update in place instead of full re-render
  # ============================================================================
  
  defp update_menu_graph(graph, old_mode, new_mode, _new_state, _theme) when old_mode == new_mode do
    # No change, return graph as-is
    graph
  end
  
  defp update_menu_graph(graph, _old_mode, new_mode, new_state, theme) do
    # Only update dropdowns since FloatButton handles its own highlighting
    update_dropdowns(graph, new_mode, new_state, theme)
  end
  
  defp update_button_highlights(graph, _new_mode, _new_state) do
    # data = new_state.data  # Currently unused
    
    # For now, we'll avoid updating individual buttons since FloatButton components
    # manage their own highlighting. The hover highlighting happens in FloatButton itself.
    # This is more efficient than re-rendering, and the visual feedback already works.
    graph
  end
  
  defp render_main_menu_bar_content(graph, data, mode) do
    frame = data.frame
    
    graph
    |> Scenic.Primitives.rect({frame.size.width, frame.size.height}, 
      fill: data.colors.background, 
      id: :menu_background
    )
    |> render_menu_buttons_for_mode(data, mode)
  end
  
  defp render_menu_buttons_for_mode(graph, data, mode) do
    data.menu_map
    |> Enum.map(fn {:sub_menu, label, _sub_menu} -> label end)
    |> Enum.with_index(1)
    |> Enum.reduce(graph, fn {label, index}, acc_graph ->
      button_width = calculate_button_width(data, label)
      
      # Determine if this button should be highlighted
      highlight? = case mode do
        :inactive -> false
        {:hover, [hover_index]} when hover_index == index -> true
        {:hover, [hover_index | _]} when hover_index == index -> true
        _ -> false
      end
      
      clipped_label = clip_text_to_width(label, button_width - (data.text_margin * 2), 
        calculate_font_data(data.font), data.text_clipping)
      
      # Create complete theme for menu buttons
      menu_button_theme = %{
        active: data.colors.button || data.colors.background,
        highlight: data.colors.button_hover || data.colors.button_active,
        text: data.colors.text,
        background: data.colors.background,
        border: data.colors.border || data.colors.text,
        thumb: data.colors.button_hover || data.colors.button_active,
        focus: data.colors.button_active || data.colors.button_hover
      }
      
      acc_graph
      |> FloatButton.add_to_graph(%{
        label: clipped_label,
        unique_id: [index],
        font: calculate_font_data(data.font),
        frame: %{
          pin: {(index - 1) * (button_width + data.button_spacing), 0},
          size: {button_width, data.frame.size.height}
        },
        margin: data.text_margin,
        hover_highlight?: highlight?
      }, theme: menu_button_theme)
    end)
  end
  
  defp update_dropdowns(graph, new_mode, new_state, theme) do
    case new_mode do
      :inactive ->
        # Remove all dropdowns
        remove_all_dropdowns(graph)
      {:hover, hover_chain} ->
        # Calculate which dropdowns should be visible
        dropdowns = calculate_dropdowns(new_state.data, hover_chain)
        update_dropdown_visibility(graph, dropdowns, new_state, theme)
    end
  end
  
  defp remove_all_dropdowns(graph) do
    # Remove all dropdown groups from the graph
    # This is more efficient than re-rendering everything
    case Scenic.Graph.get(graph, :sub_menu_collection) do
      [] -> graph  # No dropdowns to remove
      _primitive -> Scenic.Graph.delete(graph, :sub_menu_collection)
    end
  end
  
  defp update_dropdown_visibility(graph, dropdowns, new_state, theme) do
    case dropdowns do
      [] ->
        # No dropdowns needed, remove them
        remove_all_dropdowns(graph)
      dropdown_list ->
        # Add or update dropdown collection
        case Scenic.Graph.get(graph, :sub_menu_collection) do
          [] ->
            # Create dropdowns from scratch
            render_new_dropdowns(graph, dropdown_list, new_state, theme)
          _primitive ->
            # Update existing dropdowns (this could be more sophisticated)
            # For now, replace the entire dropdown collection
            graph
            |> Scenic.Graph.delete(:sub_menu_collection)
            |> render_new_dropdowns(dropdown_list, new_state, theme)
        end
    end
  end
  
  defp render_new_dropdowns(graph, dropdown_list, new_state, theme) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        render_dropdown_list(graph, new_state.data, theme, dropdown_list)
      end,
      id: :sub_menu_collection
    )
  end
end
defmodule Flamelex.GUI.Components.MemexEnvIndicator do
  @moduledoc """
  Displays the current memex environment name in the top-right corner.
  
  This helps users:
  1. Know which environment they're working in
  2. Avoid accidentally modifying the wrong memex
  3. Distinguish between dev/test/prod environments
  
  The indicator only appears when a memex environment is active.
  """
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives
  
  @indicator_width 196  # Slightly smaller to show border
  @indicator_height 56  # Slightly smaller to show border  
  @padding 2  # Small padding to show border on all sides
  
  # Environment colors for visual distinction
  @env_colors %{
    "dev" => :dodger_blue,
    "development" => :dodger_blue,
    "test" => :lime_green,
    "testing" => :lime_green,
    "prod" => :crimson,
    "production" => :crimson,
    "default" => :slate_blue
  }
  
  def validate(data) do
    {:ok, data}
  end
  
  def init(scene, _args, opts) do
    require Logger
    Logger.info("🔧 MemexEnvIndicator component initializing...")
    
    # Get viewport dimensions for positioning
    viewport_width = opts[:viewport_width] || 1024
    Logger.info("🔧 MemexEnvIndicator viewport_width: #{viewport_width}")
    
    # Get current state
    state = Flamelex.Fluxus.RadixStore.get()
    
    # Check if memex is active
    case state do
      %{memex: %{env: %{name: env_name}}} when env_name != nil ->
        Logger.info("🔧 MemexEnvIndicator rendering for environment: #{env_name}")
      _ ->
        Logger.info("🔧 MemexEnvIndicator no memex environment active")
    end
    
    # Build initial graph
    graph = render(state, viewport_width)
    
    # Initialize scene
    scene = scene
    |> assign(radix_state: state)
    |> assign(viewport_width: viewport_width)
    |> push_graph(graph)
    
    # Request input events to receive clicks
    request_input(scene, [:cursor_button])
    Logger.info("🔧 MemexEnvIndicator requested cursor_button input events")
    
    # Subscribe to state changes
    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)
    
    Logger.info("🔧 MemexEnvIndicator initialization complete")
    {:ok, scene}
  end
  
  def handle_info({:radix_state_change, new_state}, scene) do
    # Only re-render if memex environment changed
    old_env = get_in(scene.assigns.radix_state, [:memex, :env])
    new_env = get_in(new_state, [:memex, :env])
    
    # Handle the case where env is a struct - extract the name field
    old_env_name = case old_env do
      %{name: name} -> name
      _ -> nil
    end
    
    new_env_name = case new_env do
      %{name: name} -> name
      _ -> nil
    end
    
    if old_env_name != new_env_name do
      graph = render(new_state, scene.assigns.viewport_width)
      
      scene = scene
      |> assign(radix_state: new_state)
      |> push_graph(graph)
      
      {:noreply, scene}
    else
      scene = scene |> assign(radix_state: new_state)
      {:noreply, scene}
    end
  end
  
  defp render(%{memex: %{env: %{name: env_name}}} = _state, viewport_width) when env_name != nil do
    # Determine color based on environment name
    color = get_env_color(env_name)
    
    # Calculate position (top-right corner with small padding for border)
    x_pos = viewport_width - @indicator_width - @padding
    y_pos = @padding
    
    Graph.build()
    # Add hidden semantic marker text element (like Quillex does)
    |> text("",
      id: {:semantic_memex_env_indicator, env_name},
      hidden: true,
      semantic: %{
        type: :button,
        role: :button,
        label: "Memex Environment: #{env_name}",
        action: :open_rapid_selector,
        clickable: true,
        component_type: :memex_env_indicator,
        description: "Shows current memex environment. Click to open Rapid Selector."
      })
    # The visible widget group
    |> group(
      fn g ->
        g
        # Background with right angle corners
        |> rectangle({@indicator_width, @indicator_height},
          fill: color,
          stroke: {2, darken_color(color)})
        # Environment name (no icon, just text)
        |> text(truncate_name(env_name),
          fill: :white,
          font_size: 18,
          font: :ibm_plex_mono,
          translate: {15, 40})
      end,
      translate: {x_pos, y_pos},
      id: :memex_env_indicator
    )
  end
  
  defp render(_no_memex, _viewport_width) do
    # Return empty graph when no memex is active
    Graph.build()
  end
  
  defp get_env_color(env_name) do
    # Check if the environment name contains any key words
    normalized = String.downcase(env_name)
    
    Enum.find_value(@env_colors, @env_colors["default"], fn {pattern, color} ->
      if String.contains?(normalized, pattern), do: color
    end)
  end
  
  defp darken_color(:dodger_blue), do: :dark_blue
  defp darken_color(:lime_green), do: :dark_green
  defp darken_color(:crimson), do: :dark_red
  defp darken_color(:slate_blue), do: :dark_slate_blue
  defp darken_color(color), do: color
  
  defp truncate_name(name) when byte_size(name) > 20 do
    String.slice(name, 0, 17) <> "..."
  end
  defp truncate_name(name), do: name
  
  # Click handler to navigate to Rapid Selector
  def handle_input({:cursor_button, {:btn_left, 1, _, {x, y}}}, context, scene) do
    require Logger
    
    # Only handle clicks within the indicator bounds
    if click_within_bounds?(x, y, scene.assigns.viewport_width) do
      Logger.info("🖱️  MEMEX WIDGET CLICKED! Navigating to Rapid Selector...")
      
      # Navigate to the Rapid Selector page when clicked
      result = Flamelex.Fluxus.action({Flamelex.GUI.Component.RapidSelector, :open_memex})
      Logger.info("🎯 Rapid Selector action result: #{inspect(result)}")
    else
      Logger.debug("🔧 Click outside MemexEnvIndicator bounds, ignoring...")
    end
    
    {:noreply, scene}
  end
  
  # Check if click coordinates are within the indicator bounds
  defp click_within_bounds?(x, y, viewport_width) do
    indicator_x = viewport_width - @indicator_width - @padding
    indicator_y = @padding
    
    x >= indicator_x && 
    x <= indicator_x + @indicator_width &&
    y >= indicator_y && 
    y <= indicator_y + @indicator_height
  end
  
  def handle_input(input, _context, scene) do
    require Logger
    Logger.info("🔧 MemexEnvIndicator received input: #{inspect(input)}")
    {:noreply, scene}
  end
end
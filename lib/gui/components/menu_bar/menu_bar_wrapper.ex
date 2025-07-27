defmodule Flamelex.GUI.Components.MenuBar.Wrapper do
  @moduledoc """
  Wrapper component that integrates ScenicWidgets.MenuBar into Flamelex.
  
  ## Integration Architecture
  
  This component bridges the gap between Flamelex's existing menu system and the
  polished ScenicWidgets.MenuBar component developed in scenic-widget-contrib.
  
  ### Integration Flow:
  ```
  Flamelex Layer2 → MenuBar.Wrapper → MenuAdapter → ScenicWidgets.MenuBar
  ```
  
  ### Key Responsibilities:
  
  1. **Format Conversion**: Converts Flamelex menu format to ScenicWidgets format
     - Flamelex: `[{:sub_menu, "Label", [{"item", &function/0}, ...]}]`
     - ScenicWidgets: `[menu_id: {"Label", [{item_id, "Item"}, ...]}, ...]`
  
  2. **Event Routing**: Handles menu clicks and executes associated functions
     - Receives `:menu_item_clicked` events from ScenicWidgets.MenuBar
     - Maps item IDs back to original functions and executes them
  
  3. **Theme Integration**: Applies Flamelex's dark theme to the MenuBar
  
  4. **State Management**: Maintains reference to original menu map for function execution
  
  ### Benefits of Integration:
  
  - **Polished UI**: Uses the refined MenuBar with triangle indicators, grace areas, and proper input handling
  - **Maintainability**: Leverages the well-tested ScenicWidgets.MenuBar component
  - **Compatibility**: Preserves all existing Flamelex menu functionality
  - **Future-Proof**: Benefits from improvements made to the shared component
  
  ### Usage:
  
  Used in Layer2.Renderizer as a drop-in replacement for the original MenuBar:
  ```elixir
  |> Flamelex.GUI.Components.MenuBar.Wrapper.add_to_graph(
    %{frame: frame, menu_map: menu_map},
    id: :flamelex_menubar
  )
  ```
  """
  
  use Scenic.Component
  alias Scenic.Graph
  alias Flamelex.GUI.Components.MenuBar.MenuAdapter
  require Logger
  
  @impl Scenic.Component
  def validate(data) do
    # Extract frame and menu_map from the data
    frame = Map.get(data, :frame)
    menu_map = Map.get(data, :menu_map, [])
    
    {:ok, %{frame: frame, original_menu_map: menu_map}}
  end
  
  @impl Scenic.Component
  def init(scene, %{frame: frame, original_menu_map: menu_map}, _opts) do
    Logger.info("MenuBar.Wrapper init with menu_map: #{inspect(menu_map, pretty: true)}")
    
    # Build a function registry from the menu map
    function_registry = build_function_registry(menu_map)
    Logger.info("Built function registry with #{map_size(function_registry)} entries")
    
    # Convert Flamelex menu format to ScenicWidgets format
    scenic_menu_map = MenuAdapter.convert_to_scenic_widgets(menu_map)
    Logger.info("Converted menu_map: #{inspect(scenic_menu_map, pretty: true)}")
    
    # Build the graph with ScenicWidgets.MenuBar
    graph = Graph.build()
    |> ScenicWidgets.MenuBar.add_to_graph(
      %{
        menu_map: scenic_menu_map,
        frame: frame,
        theme: %{
          background: :dark_gray,
          text: :white,
          hover_bg: :steel_blue,
          hover_text: :white,
          dropdown_bg: :light_gray,
          dropdown_text: :black,
          dropdown_hover_bg: :dodger_blue,
          dropdown_hover_text: :white
        }
      },
      id: :scenic_menubar
    )
    
    scene = scene
    |> assign(graph: graph)
    |> assign(original_menu_map: menu_map)
    |> assign(function_registry: function_registry)
    |> push_graph(graph)
    
    {:ok, scene}
  end
  
  # Build a registry mapping menu item labels to their functions
  defp build_function_registry(menu_map) do
    menu_map
    |> Enum.reduce(%{}, fn item, acc ->
      extract_functions(item, acc)
    end)
  end
  
  defp extract_functions({:sub_menu, _label, items}, acc) do
    Enum.reduce(items, acc, &extract_functions/2)
  end
  
  defp extract_functions({label, function}, acc) when is_function(function, 0) do
    Map.put(acc, label, function)
  end
  
  defp extract_functions(_, acc), do: acc
  
  @impl Scenic.Component
  def handle_event({:menu_item_clicked, item_id}, _from, scene) do
    Logger.info("MenuBar wrapper received click: #{inspect(item_id)}")
    
    # Look up the function in our registry
    function_registry = scene.assigns.function_registry
    
    case Map.get(function_registry, item_id) do
      function when is_function(function, 0) ->
        Logger.info("Executing function for menu item: #{item_id}")
        try do
          result = function.()
          Logger.info("Menu function executed successfully: #{inspect(result)}")
        rescue
          e ->
            Logger.error("Error executing menu function for #{item_id}: #{inspect(e)}")
        end
        
      nil ->
        Logger.warn("No function found in registry for menu item: #{item_id}")
        Logger.debug("Function registry: #{inspect(function_registry)}")
    end
    
    {:noreply, scene}
  end
  
  # Handle input that gets forwarded from the MenuBar component
  def handle_input(input, context, scene) do
    Logger.debug("MenuBar wrapper received input: #{inspect(input)}")
    # Let the child component handle its own input
    {:noreply, scene}
  end
  
  # Handle close_all_menus message
  def handle_cast(:close_all_menus, scene) do
    # Forward to the actual MenuBar component
    GenServer.cast(:scenic_menubar, :close_all_menus)
    {:noreply, scene}
  end
  
  def handle_cast(msg, scene) do
    Logger.debug("MenuBar wrapper received cast: #{inspect(msg)}")
    {:noreply, scene}
  end
end
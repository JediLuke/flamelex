defmodule Flamelex.GUI.Components.MenuBar.MenuAdapter do
  @moduledoc """
  Adapter to convert between Flamelex menu format and ScenicWidgets.MenuBar format.
  
  ## Format Conversion
  
  This module enables the integration of ScenicWidgets.MenuBar into Flamelex by
  converting between the two different menu data structures.
  
  ### Flamelex Format (Input):
  ```elixir
  [
    {:sub_menu, "File", [
      {"New", &FileActions.new/0},
      {"Open", &FileActions.open/0},
      {:sub_menu, "Recent", [
        {"file1.txt", &RecentActions.open_file1/0}
      ]}
    ]},
    {:sub_menu, "Edit", [
      {"Copy", &EditActions.copy/0}
    ]}
  ]
  ```
  
  ### ScenicWidgets Format (Output):
  ```elixir
  [
    file: {"File", [
      {"New", "New"},
      {"Open", "Open"},  
      {:sub_menu, "Recent", [{"file1.txt", "file1.txt"}]}
    ]},
    edit: {"Edit", [
      {"Copy", "Copy"}
    ]}
  ]
  ```
  
  ## Function Execution
  
  The adapter maintains a mapping between item labels and their associated functions,
  enabling the execution of menu actions when items are clicked in the UI.
  
  ### Key Features:
  
  - **Bidirectional Mapping**: Converts formats while preserving function references
  - **Nested Menu Support**: Handles sub-menus and sub-sub-menus recursively  
  - **Error Handling**: Graceful handling of missing functions or conversion errors
  - **Function Execution**: Safe execution of menu functions with error logging
  
  ## Integration Context
  
  This adapter was created as part of integrating the polished ScenicWidgets.MenuBar
  component (developed in scenic-widget-contrib) into Flamelex. It allows Flamelex
  to benefit from the improved MenuBar while maintaining compatibility with existing
  menu definitions and functions.
  """
  
  @doc """
  Convert Flamelex menu_map to ScenicWidgets format
  """
  def convert_to_scenic_widgets(flamelex_menu_map) do
    # Handle empty or nil menu map
    flamelex_menu_map = flamelex_menu_map || []
    
    # Convert to the format expected by ScenicWidgets.MenuBar
    # It expects: [{:sub_menu, label, items}, ...]
    flamelex_menu_map
    |> Enum.map(fn {:sub_menu, label, items} ->
      {:sub_menu, label, convert_items(items)}
    end)
  end
  
  @doc """
  Convert menu items, handling both action items and sub-menus
  """
  defp convert_items(items) do
    items
    |> Enum.map(fn
      {label, function} when is_function(function, 0) ->
        # IMPORTANT: ScenicWidgets.MenuBar expects {id, label} format
        # But we need to preserve the function for execution
        # The label serves as both the ID and display text
        # The function will be found later via the original menu map
        {label, label}
        
      {:sub_menu, label, sub_items} ->
        # Keep sub-menu format as-is, but convert nested items
        {:sub_menu, label, convert_items(sub_items)}
        
      other ->
        # Log unexpected format
        require Logger
        Logger.warn("Unexpected menu item format in convert_items: #{inspect(other)}")
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end
  
  @doc """
  Handle menu item clicks by finding and executing the associated function
  """
  def handle_menu_click(item_id, original_menu_map) when is_binary(item_id) do
    require Logger
    Logger.info("MenuAdapter handling click for item: #{inspect(item_id)}")
    
    # Search through the original menu map to find the function
    function = find_function_by_id(item_id, original_menu_map)
    
    if function && is_function(function, 0) do
      try do
        Logger.info("Executing function for menu item: #{item_id}")
        result = function.()
        Logger.info("Menu function executed successfully: #{inspect(result)}")
        :ok
      rescue
        e ->
          Logger.error("Error executing menu function for #{item_id}: #{inspect(e)}")
          {:error, e}
      end
    else
      Logger.warn("No function found for menu item: #{item_id} (found: #{inspect(function)})")
      
      # For debugging - let's see what's in the menu map
      Logger.info("Original menu map structure: #{inspect(original_menu_map, pretty: true)}")
      
      {:error, :not_found}
    end
  end
  
  defp find_function_by_id(item_id, menu_map) do
    Enum.reduce_while(menu_map, nil, fn
      {:sub_menu, _label, items}, _acc ->
        case find_in_items(item_id, items) do
          nil -> {:cont, nil}
          function -> {:halt, function}
        end
    end)
  end
  
  defp find_in_items(item_id, items) do
    Enum.reduce_while(items, nil, fn
      {label, function}, _acc when is_function(function, 0) ->
        # Match on the label directly since we're using label as ID
        if label == item_id do
          {:halt, function}
        else
          {:cont, nil}
        end
        
      {label, _non_function}, _acc ->
        # Skip non-function items gracefully
        if label == item_id do
          require Logger
          Logger.warn("Found menu item '#{item_id}' but it's not a function")
          {:halt, :not_a_function}
        else
          {:cont, nil}
        end
        
      {:sub_menu, _label, sub_items}, _acc ->
        case find_in_items(item_id, sub_items) do
          nil -> {:cont, nil}
          function -> {:halt, function}
        end
        
      other, _acc ->
        # Handle any other unexpected formats
        require Logger
        Logger.warn("Unexpected menu item format: #{inspect(other)}")
        {:cont, nil}
    end)
  end
end
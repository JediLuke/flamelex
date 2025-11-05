defmodule Flamelex.GUI.Menus.MenuHelpers do
  @moduledoc """
  Helper functions for constructing Flamelex menus using
  scenic-widget-contrib utilities.

  This module provides a bridge between Flamelex's menu system
  and the MenuMapMaker utilities from scenic-widget-contrib.
  """

  @doc """
  Builds a nested menu structure from all zero-arity functions
  in modules under a base module path.

  ## Example

      iex> MenuHelpers.modules_and_zero_arity_functions("Elixir.Flamelex.API")
      [
        {:sub_menu, "Buffer", [
          {"new", &Flamelex.API.Buffer.new/0},
          {"save", &Flamelex.API.Buffer.save/0}
        ]},
        {:sub_menu, "Kommander", [
          {"show", &Flamelex.API.Kommander.show/0}
        ]}
      ]

  Delegates to ScenicWidgets.MenuBar.MenuMapMaker.modules_and_zero_arity_functions/1
  """
  defdelegate modules_and_zero_arity_functions(base_module),
    to: ScenicWidgets.MenuBar.MenuMapMaker

  @doc """
  Extracts all zero-arity functions from a module and returns them
  as menu items with function closures.

  ## Example

      iex> MenuHelpers.zero_arity_functions("Elixir.Flamelex.API.Buffer")
      [
        {"new", &Flamelex.API.Buffer.new/0},
        {"save", &Flamelex.API.Buffer.save/0},
        {"close", &Flamelex.API.Buffer.close/0}
      ]

  Delegates to ScenicWidgets.MenuBar.MenuMapMaker.zero_arity_functions/1
  """
  defdelegate zero_arity_functions(module_name),
    to: ScenicWidgets.MenuBar.MenuMapMaker

  @doc """
  Convenience function to build an API menu from a base module path.
  Returns a menu structure compatible with Flamelex's format.

  ## Example

      iex> MenuHelpers.build_api_menu("Elixir.Flamelex.API")
      {:sub_menu, "API", [...]}
  """
  def build_api_menu(base_module_path) do
    {:sub_menu, "API", modules_and_zero_arity_functions(base_module_path)}
  end

  @doc """
  Converts menu items from Flamelex's 2-tuple format {label, function}
  to the scenic-widget-contrib 3-tuple format {id, label, function}.

  This ensures compatibility with the MenuBar component which expects
  the ID to be the first element.

  Recursively handles nested sub-menus.
  """
  def convert_to_menubar_format(items) when is_list(items) do
    Enum.map(items, &convert_menu_item/1)
  end

  defp convert_menu_item({:sub_menu, label, sub_items}) do
    # Recursively convert sub-menu items
    {:sub_menu, label, convert_to_menubar_format(sub_items)}
  end

  defp convert_menu_item({label, action_fn}) when is_binary(label) and is_function(action_fn) do
    # Convert {label, fn} to {id, label, fn}
    # Generate ID from label: "Save Buffer" -> "save_buffer"
    id = label
         |> String.downcase()
         |> String.replace(~r/[^a-z0-9]+/, "_")
         |> String.trim("_")

    {id, label, action_fn}
  end

  defp convert_menu_item(item) do
    # Pass through items that are already in the correct format
    item
  end
end

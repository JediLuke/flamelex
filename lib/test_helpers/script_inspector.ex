defmodule Flamelex.TestHelpers.ScriptInspector do
  @moduledoc """
  Helper functions for inspecting the Scenic script table to extract rendered content.

  These functions provide true end-to-end testing by examining what actually gets
  rendered to the screen, rather than just checking internal application state.
  
  This is specialized for Flamelex GUI inspection.
  """

  @doc """
  Extract all text content from the script table that is currently being rendered.
  Returns a list of text strings found in the rendering scripts.
  """
  def extract_rendered_text do
    try do
      case ScenicMcp.Probes.script_table() do
        script_entries when is_list(script_entries) ->
          script_entries
          |> Enum.flat_map(&extract_text_from_script_entry/1)
          |> Enum.uniq()

        _ -> []
      end
    rescue
      error ->
        IO.puts("Error extracting rendered text: #{inspect(error)}")
        []
    end
  end

  @doc """
  Check if any rendered content contains the specified string.
  This looks at all rendered text including GUI elements.
  """
  def rendered_text_contains?(text) when is_binary(text) do
    extract_rendered_text()
    |> Enum.any?(fn rendered_text ->
      String.contains?(rendered_text, text)
    end)
  end

  @doc """
  Get all rendered text as a single string for easier inspection.
  """
  def get_rendered_text_string do
    extract_rendered_text()
    |> Enum.join(" ")
  end

  @doc """
  Check if the rendered output appears to be empty (no content).
  """
  def rendered_text_empty? do
    text_content = extract_rendered_text()

    text_content == [] or
    Enum.all?(text_content, fn text ->
      String.trim(text) == ""
    end)
  end

  @doc """
  Extract Flamelex-specific UI elements that indicate the app is running.
  Returns a list of UI indicators found.
  """
  def extract_flamelex_ui_indicators do
    rendered_text = extract_rendered_text()
    
    indicators = [
      "Flamelex",
      "Buffer",
      "Command",
      "Mode",
      "File",
      "Edit",
      "Search",
      "Tools",
      "Help"
    ]
    
    Enum.filter(indicators, fn indicator ->
      Enum.any?(rendered_text, &String.contains?(&1, indicator))
    end)
  end

  @doc """
  Check if Flamelex appears to be fully loaded by looking for key UI elements.
  """
  def flamelex_appears_loaded? do
    indicators = extract_flamelex_ui_indicators()
    
    # If we see at least one Flamelex UI element, consider it loaded
    length(indicators) > 0
  end

  # Private helper functions

  defp extract_text_from_script_entry(script_entry) do
    case script_entry do
      # Text primitive with content
      {_id, {:text, text, _opts}} when is_binary(text) ->
        [text]

      # Nested script entries
      {_id, nested_entries} when is_list(nested_entries) ->
        Enum.flat_map(nested_entries, &extract_text_from_script_entry/1)

      # Other script types that might contain text
      script when is_tuple(script) ->
        script
        |> Tuple.to_list()
        |> Enum.flat_map(fn
          text when is_binary(text) -> [text]
          nested when is_list(nested) -> Enum.flat_map(nested, &extract_text_from_nested/1)
          _ -> []
        end)

      _ -> []
    end
  end

  defp extract_text_from_nested(item) do
    case item do
      text when is_binary(text) -> [text]
      {_key, text} when is_binary(text) -> [text]
      tuple when is_tuple(tuple) -> 
        tuple
        |> Tuple.to_list() 
        |> Enum.flat_map(&extract_text_from_nested/1)
      list when is_list(list) -> 
        Enum.flat_map(list, &extract_text_from_nested/1)
      _ -> []
    end
  end
end
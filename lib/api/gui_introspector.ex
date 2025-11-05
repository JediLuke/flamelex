defmodule Flamelex.API.GUIIntrospector do
  @moduledoc """
  A tool to introspect the current GUI state by analyzing the script data
  captured by the ScriptInterceptorDriver.
  """

  def describe_current_scene do
    case Flamelex.API.ScriptAnalysis.get_stats() do
      %{total_scripts: 0} ->
        "The canvas lies dormant, a blank expanse awaiting the first stroke of creation."
      
      stats ->
        analyze_rendering_activity(stats)
    end
  end

  def get_latest_script_summary do
    case Flamelex.API.ScriptAnalysis.get_latest_script() do
      nil -> 
        "No rendering scripts captured yet."
      
      script_data ->
        summarize_script_commands(script_data)
    end
  end

  defp analyze_rendering_activity(%{total_scripts: count, total_size: size}) do
    """
    The digital canvas pulses with life - #{count} rendering scripts have painted their visions,
    weaving #{format_bytes(size)} of graphical poetry across the screen. Each script a brushstroke
    in the grand composition of your memex interface.
    """
  end

  defp summarize_script_commands(script_data) when is_binary(script_data) do
    # Try to decode the script data to understand what's being rendered
    case analyze_script_content(script_data) do
      {:ok, summary} -> summary
      {:error, _} -> "Ancient script data flows in patterns too complex to decipher..."
    end
  end

  defp analyze_script_content(script_data) do
    # This is a simplified analysis - in reality, we'd need to parse the actual
    # Scenic script format to understand what's being drawn
    cond do
      String.contains?(script_data, "text") ->
        {:ok, "Text elements dance across the interface, carrying words of wisdom and navigation."}
      
      String.contains?(script_data, "rect") ->
        {:ok, "Geometric forms take shape - rectangles defining boundaries and structure."}
      
      String.contains?(script_data, "menu") ->
        {:ok, "A menubar stretches across the horizon, offering pathways to hidden realms."}
      
      true ->
        {:ok, "Mysterious rendering commands flow like digital ink across the canvas."}
    end
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} bytes"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"
end

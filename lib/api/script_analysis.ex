defmodule Flamelex.API.ScriptAnalysis do
  @moduledoc """
  Public API for accessing script analysis functionality.
  
  This module provides a clean interface for other parts of Flamelex
  to interact with the script interception and analysis system.
  """
  
  alias Flamelex.API.ScriptAnalysis.ScriptAnalyzer
  
  @doc """
  Get current script analysis statistics.
  
  Returns a map containing:
  - script_count: Total number of scripts processed
  - total_bytes: Total bytes of script data processed
  - uptime_ms: How long the analyzer has been running
  - recent_events: List of recent script events
  - avg_script_size: Average size of scripts in bytes
  """
  def get_stats do
    ScriptAnalyzer.get_stats()
  end
  
  @doc """
  Get recent script data.
  
  Returns a list of the most recent scripts with their metadata.
  """
  def get_recent_scripts(limit \\ 10) do
    ScriptAnalyzer.get_recent_scripts(limit)
  end
  
  @doc """
  Clear all collected script analysis data.
  
  Useful for resetting the analysis state during development.
  """
  def clear_data do
    ScriptAnalyzer.clear_data()
  end
  
  @doc """
  Print a formatted summary of script analysis to the console.
  
  Useful for quick debugging and development.
  """
  def print_summary do
    stats = get_stats()
    
    IO.puts("\n=== Script Analysis Summary ===")
    IO.puts("Scripts processed: #{stats.script_count}")
    IO.puts("Total bytes: #{stats.total_bytes}")
    IO.puts("Average script size: #{Float.round(stats.avg_script_size, 2)} bytes")
    IO.puts("Uptime: #{stats.uptime_ms}ms")
    
    if length(stats.recent_events) > 0 do
      IO.puts("\nRecent events:")
      Enum.each(stats.recent_events, fn event ->
        IO.puts("  #{event.type}: #{inspect(event.data)}")
      end)
    end
    
    IO.puts("===============================\n")
  end
  
  @doc """
  Check if script analysis is active and working.
  
  Returns true if the analyzer is running and has processed scripts.
  """
  def active? do
    try do
      stats = get_stats()
      stats.script_count > 0
    rescue
      _ -> false
    end
  end
end

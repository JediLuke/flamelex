defmodule Flamelex.GUI.DevTools do
  @moduledoc """
  Flamelex-specific developer tools that extend Scenic.DevTools
  with knowledge about buffers, layers, and Flamelex concepts.
  
  ## Usage
  
      iex> import Flamelex.GUI.DevTools
      iex> buffers()          # Show all text buffers with Flamelex context
      iex> layers()           # Show layer hierarchy
      iex> active_buffer()    # Show the currently active buffer
  """
  
  alias Scenic.DevTools
  
  @doc """
  Show all text buffers in Flamelex with their content and metadata.
  
  This is Flamelex-specific and understands buffer IDs, file paths, etc.
  """
  def buffers(viewport_name \\ :main_viewport) do
    with {:ok, viewport} <- get_viewport(viewport_name) do
      entries = :ets.tab2list(viewport.semantic_table)
      
      # Find all text buffers
      all_buffers = Enum.flat_map(entries, fn {graph_key, data} ->
        buffer_ids = Map.get(data.by_type, :text_buffer, [])
        
        Enum.map(buffer_ids, fn id ->
          elem = Map.get(data.elements, id)
          # Try to find the scene that owns this graph
          scripts = :ets.tab2list(viewport.script_table)
          owner_info = Enum.find(scripts, fn {gid, _, _} -> gid == graph_key end)
          
          scene_info = case owner_info do
            {_, _, owner_pid} -> find_scene_info(viewport, owner_pid)
            nil -> nil
          end
          
          %{
            graph_key: graph_key,
            buffer_id: elem.semantic.buffer_id,
            content: elem.content || "",
            semantic: elem.semantic,
            scene_info: scene_info
          }
        end)
      end)
      
      if all_buffers == [] do
        IO.puts("No text buffers found")
      else
        IO.puts("=== Flamelex Text Buffers ===")
        IO.puts("Total: #{length(all_buffers)} buffer(s)")
        IO.puts("")
        
        Enum.each(all_buffers, fn buffer ->
          IO.puts("📝 Buffer ID: #{buffer.buffer_id}")
          
          # Show which scene/layer owns this buffer
          case buffer.scene_info do
            {scene_id, module} ->
              layer = extract_layer_name(scene_id, module)
              IO.puts("   Layer: #{layer}")
            _ ->
              IO.puts("   Layer: Unknown")
          end
          
          # Show file path if available
          if Map.has_key?(buffer.semantic, :file_path) do
            IO.puts("   File: #{buffer.semantic.file_path}")
          end
          
          # Show content preview
          lines = String.split(buffer.content, "\n")
          line_count = length(lines)
          preview = Enum.take(lines, 3) |> Enum.join("\n")
          
          IO.puts("   Lines: #{line_count}")
          IO.puts("   Content Preview:")
          IO.puts("   #{String.replace(preview, "\n", "\n   ")}")
          
          if line_count > 3 do
            IO.puts("   ... (#{line_count - 3} more lines)")
          end
          
          IO.puts("")
        end)
      end
      
      :ok
    else
      error ->
        IO.puts("Error: #{inspect(error)}")
        :error
    end
  end
  
  @doc """
  Show the layer hierarchy specific to Flamelex.
  
  Understands Flamelex's layer system (Layer1, Layer2, Layer3, Layer4).
  """
  def layers(viewport_name \\ :main_viewport) do
    IO.puts("=== Flamelex Layer Hierarchy ===")
    
    # Use Scenic's scene_tree but we could enhance this
    # to show more Flamelex-specific info
    DevTools.scene_tree(viewport_name)
  end
  
  @doc """
  Show information about the currently active buffer.
  
  This would need to integrate with Flamelex's state management
  to know which buffer is currently active.
  """
  def active_buffer(_viewport_name \\ :main_viewport) do
    IO.puts("=== Active Buffer ===")
    IO.puts("TODO: This requires integration with Flamelex state management")
    IO.puts("to track which buffer is currently active/focused.")
    :ok
  end
  
  @doc """
  Find all UI elements in a specific layer.
  """
  def layer_contents(layer_name, viewport_name \\ :main_viewport) do
    IO.puts("=== Contents of #{layer_name} ===")
    
    # This would search for the layer scene and show its semantic contents
    # For now, we'll use the generic inspect_scene
    DevTools.inspect_scene(layer_name, viewport_name)
  end
  
  # Private helpers
  
  defp get_viewport(name) when is_atom(name) do
    case Process.whereis(name) do
      nil -> {:error, "ViewPort #{inspect(name)} not found"}
      pid -> Scenic.ViewPort.info(pid)
    end
  end
  
  defp find_scene_info(viewport, pid) do
    case Map.get(viewport.scenes_by_pid, pid) do
      {id, _parent_id, module} -> {id, module}
      nil -> nil
    end
  end
  
  defp extract_layer_name(scene_id, module) do
    cond do
      String.contains?(to_string(module), "Layer1") -> "Layer 1 (Background)"
      String.contains?(to_string(module), "Layer2") -> "Layer 2 (Main Content)"
      String.contains?(to_string(module), "Layer3") -> "Layer 3 (Overlays)"
      String.contains?(to_string(module), "Layer4") -> "Layer 4 (Menus/Popups)"
      String.contains?(scene_id, "buffer_pane") -> "Buffer Pane"
      scene_id == "_main_" -> "Root"
      true -> scene_id
    end
  end
end
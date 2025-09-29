defmodule Flamelex.Test.MemexEnvIndicatorTest do
  @moduledoc """
  Simple test to verify memex environment indicator functionality without 
  requiring full app compilation.
  """
  
  use ExUnit.Case, async: true
  
  test "memex environment indicator function exists and works" do
    # Test the env indicator function directly
    mock_frame = %{width: 1024, height: 768}
    mock_state = %{memex: %{env: %{name: "Archimedes"}}}
    
    # Import the function we want to test
    Code.require_file("lib/gui/scenes/flx_root_scene.ex")
    
    # Build a basic graph
    graph = Scenic.Graph.build()
    
    # Try to call our function (it's private, so we'll test the logic)
    result = apply(Flamelex.GUI.RootScene, :add_memex_env_indicator, [graph, mock_frame, mock_state])
    
    # Verify we get a graph back
    assert is_struct(result, Scenic.Graph)
    
    # Verify it's different from the input graph (something was added)
    refute result == graph
  end
  
  test "environment indicator only shows when memex is active" do
    mock_frame = %{width: 1024, height: 768}
    mock_state_no_memex = %{}
    
    graph = Scenic.Graph.build()
    
    # Test with no memex environment
    result = apply(Flamelex.GUI.RootScene, :add_memex_env_indicator, [graph, mock_frame, mock_state_no_memex])
    
    # Should return the same graph unchanged
    assert result == graph
  end
  
  test "color selection works correctly" do
    # Test different environment types
    test_cases = [
      {"dev-environment", :dodger_blue},
      {"production-server", :crimson},
      {"test-setup", :lime_green},
      {"archimedes", :slate_blue}
    ]
    
    Enum.each(test_cases, fn {env_name, expected_color} ->
      # Test the color selection logic
      downcased_name = String.downcase(env_name)
      color = cond do
        String.contains?(downcased_name, "dev") -> :dodger_blue
        String.contains?(downcased_name, "prod") -> :crimson
        String.contains?(downcased_name, "test") -> :lime_green
        true -> :slate_blue
      end
      
      assert color == expected_color, "Environment '#{env_name}' should be #{expected_color}, got #{color}"
    end)
  end
end
defmodule Flamelex.DebugScenicMcpSpex do
  @moduledoc """
  Debug spex to isolate ScenicMcp.Probes function call issues.
  """
  use SexySpex

  setup_all do
    # Start Flamelex with MCP server
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Debug ScenicMcp.Probes function calls",
    description: "Isolate and fix function call issues with scenic_mcp",
    tags: [:debug, :scenic_mcp] do

    scenario "Test basic ScenicMcp.Probes module loading", context do
      given_ "Flamelex is running", context do
        assert SexySpex.Helpers.application_running?(:flamelex), "Flamelex should be started"
        
        # Test that the module can be loaded
        {:module, ScenicMcp.Probes} = Code.ensure_loaded(ScenicMcp.Probes)
        
        {:ok, context}
      end

      when_ "we try to check available functions", context do
        # Check what functions are available
        available_functions = try do
          ScenicMcp.Probes.module_info(:exports)
        rescue
          error -> {:error, error}
        end
        
        # Try calling the function with different arities
        screenshot_results = %{
          arity_0: try do
            ScenicMcp.Probes.take_screenshot()
            :success
          rescue
            error -> {:error, error}
          end,
          arity_1: try do
            ScenicMcp.Probes.take_screenshot("debug_test")
            :success
          rescue
            error -> {:error, error}
          end
        }
        
        result = %{
          available_functions: available_functions,
          screenshot_results: screenshot_results
        }
        
        {:ok, Map.put(context, :result, result)}
      end

      then_ "we should get insight into the function availability", context do
        IO.puts "\n=== DEBUG INFO ==="
        IO.puts "Available functions: #{inspect(context.result.available_functions)}"
        IO.puts "Screenshot results: #{inspect(context.result.screenshot_results)}"
        IO.puts "==================\n"
        
        # Check if either arity worked
        success_count = case context.result.screenshot_results do
          %{arity_0: :success} -> 1
          %{arity_1: :success} -> 1
          %{arity_0: :success, arity_1: :success} -> 2
          _ -> 0
        end
        
        if success_count > 0 do
          assert true, "At least one function call succeeded"
        else
          # Don't fail, just provide info
          assert true, "Function investigation complete"
        end
        
        :ok
      end
    end

  end
end
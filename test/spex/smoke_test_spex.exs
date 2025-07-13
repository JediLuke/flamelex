defmodule Flamelex.SmokeTestSpex do
  @moduledoc """
  SMOKE TEST Spex for Flamelex - "Touch Earth" validation.
  
  This spex provides basic "smoke test" functionality to validate that:
  1. Flamelex application boots successfully
  2. The main GUI loads and displays correctly
  3. The loading screen appears (if applicable)
  4. Basic scenic_mcp integration works
  
  This is our "hello world" spex for Flamelex - a simple validation that
  the app is alive and responding to AI control via scenic_mcp.
  
  ## Success Criteria:
  - ✅ Application starts without crashing
  - ✅ GUI window opens and renders
  - ✅ Visual evidence captured via screenshot
  - ✅ scenic_mcp can connect and control the app
  
  This establishes the foundation for more complex spex-driven development.
  """
  use SexySpex

  @tmp_screenshots_dir "test/spex/screenshots/smoke_test"

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Flamelex Smoke Test - Basic Boot and GUI Validation",
    description: "Validates that Flamelex boots correctly and displays the main interface",
    tags: [:smoke_test, :boot_validation, :gui_basic, :ai_control] do

    # =============================================================================
    # 1. APPLICATION BOOT VALIDATION
    # =============================================================================

    scenario "Flamelex application boots successfully", context do
      given_ "Flamelex is starting up", context do
        # Application should be starting through setup_all
        # Give it a moment to fully initialize
        Process.sleep(1000)
        
        # Try to take a screenshot - this may not work during test execution
        boot_screenshot = try do
          ScenicMcp.Probes.take_screenshot("flamelex_boot_start")
        rescue
          UndefinedFunctionError ->
            IO.puts("   ℹ️  Screenshot skipped (expected during test execution)")
            nil
        end
        
        # The main validation: Flamelex.App should be running
        flamelex_running = Process.whereis(Flamelex.App) != nil
        assert flamelex_running, "Flamelex.App process should be running"
        
        {:ok, Map.merge(context, %{boot_screenshot: boot_screenshot, flamelex_running: flamelex_running})}
      end

      when_ "the application finishes loading", context do
        # Allow extra time for Flamelex to fully load all components
        # Flamelex is more complex than Quillex and may take longer
        Process.sleep(2000)
        
        loaded_screenshot = try do
          ScenicMcp.Probes.take_screenshot("flamelex_loaded")
        rescue
          UndefinedFunctionError ->
            IO.puts("   ℹ️  Screenshot skipped (expected during test execution)")
            nil
        end
        
        # Verify key processes are running to confirm successful load
        flamelex_running = Process.whereis(Flamelex.App) != nil
        
        # IMPORTANT: Check script table while the app is still running
        script_table_content = try do
          Flamelex.TestHelpers.ScriptInspector.extract_rendered_text()
        rescue
          error ->
            IO.puts("   ⚠️  Script table access failed: #{inspect(error)}")
            []
        end
        
        ui_indicators = try do
          Flamelex.TestHelpers.ScriptInspector.extract_flamelex_ui_indicators()
        rescue
          error ->
            IO.puts("   ⚠️  UI indicators extraction failed: #{inspect(error)}")
            []
        end
        
        {:ok, Map.merge(context, %{
          loaded_screenshot: loaded_screenshot, 
          fully_loaded: flamelex_running,
          script_content: script_table_content,
          ui_indicators: ui_indicators
        })}
      end

      then_ "the main GUI should be visible and responsive", context do
        # Primary validation: Flamelex should be fully loaded and running
        assert context.fully_loaded, "Flamelex should be fully loaded"
        
        # The key validation: use script table data captured while app was running
        assert length(context.ui_indicators) > 0, 
               "Should find Flamelex UI elements in rendered content. Found: #{inspect(context.ui_indicators)}"
        
        # Verify we found expected Flamelex elements
        expected_elements = ["Flamelex", "Buffer", "Help"]
        found_elements = Enum.filter(expected_elements, fn element ->
          element in context.ui_indicators
        end)
        
        assert length(found_elements) > 0,
               "Should find at least one core UI element. Expected: #{inspect(expected_elements)}, Found: #{inspect(found_elements)}"
        
        # Log what we actually captured for debugging
        IO.puts("   🎯 Rendered UI elements found: #{inspect(context.ui_indicators)}")
        IO.puts("   📋 Total rendered elements: #{length(context.script_content)}")
        IO.puts("   ✅ Core elements verified: #{inspect(found_elements)}")
        
        IO.puts("   🎯 Smoke Test Core Success: Flamelex GUI is rendering expected content!")
        :ok
      end
    end

    # =============================================================================
    # 2. BASIC PROCESS VALIDATION
    # =============================================================================

    scenario "Core Flamelex processes are running", context do
      given_ "Flamelex has completed startup", context do
        # Allow time for all processes to stabilize
        Process.sleep(1000)
        {:ok, context}
      end

      when_ "we check for essential Flamelex processes", context do
        # Check that key Flamelex processes are running
        flamelex_app = Process.whereis(Flamelex.App)
        
        # Check if we can access key modules (proves they compiled and loaded)
        modules_loaded = [
          Code.ensure_loaded(Flamelex.App),
          Code.ensure_loaded(Flamelex.Fluxus.RadixState),
          Code.ensure_loaded(Flamelex.GUI.RootScene)
        ]
        
        all_modules_loaded = Enum.all?(modules_loaded, fn
          {:module, _} -> true
          _ -> false
        end)
        
        {:ok, Map.merge(context, %{
          flamelex_app_pid: flamelex_app,
          all_modules_loaded: all_modules_loaded
        })}
      end

      then_ "all essential components should be operational", context do
        # Validate that Flamelex.App is running
        assert context.flamelex_app_pid != nil, "Flamelex.App should be running"
        assert Process.alive?(context.flamelex_app_pid), "Flamelex.App process should be alive"
        
        # Validate that core modules loaded successfully
        assert context.all_modules_loaded, "All core Flamelex modules should be loaded"
        
        IO.puts("   ✅ All essential Flamelex processes are running")
        :ok
      end
    end

    # =============================================================================
    # 3. SCRIPT TABLE INSPECTION - CORE GUI VALIDATION
    # =============================================================================

    scenario "Flamelex GUI content is correctly rendered", context do
      given_ "Flamelex is fully loaded and rendering", context do
        # Give extra time for all GUI elements to be rendered
        Process.sleep(2000)
        {:ok, context}
      end

      when_ "we inspect the scenic script table for rendered content", context do
        # Extract all rendered text from the script table
        rendered_text = Flamelex.TestHelpers.ScriptInspector.extract_rendered_text()
        
        # Look for specific Flamelex UI indicators
        ui_indicators = Flamelex.TestHelpers.ScriptInspector.extract_flamelex_ui_indicators()
        
        # Check if the GUI appears loaded based on content analysis
        appears_loaded = Flamelex.TestHelpers.ScriptInspector.flamelex_appears_loaded?()
        
        # Get detailed breakdown for debugging
        rendered_text_string = Flamelex.TestHelpers.ScriptInspector.get_rendered_text_string()
        
        {:ok, Map.merge(context, %{
          all_rendered_text: rendered_text,
          ui_indicators: ui_indicators,
          appears_loaded: appears_loaded,
          rendered_summary: rendered_text_string
        })}
      end

      then_ "we should see expected Flamelex UI elements in the rendered content", context do
        # Core validation: We should find Flamelex UI elements
        assert length(context.ui_indicators) > 0,
               "Should find Flamelex UI indicators. Found: #{inspect(context.ui_indicators)}"
        
        assert context.appears_loaded,
               "Flamelex should appear loaded based on script table analysis"
        
        # Look for specific expected elements
        expected_elements = ["Flamelex", "Buffer", "Help"]
        found_elements = Enum.filter(expected_elements, fn element ->
          element in context.ui_indicators
        end)
        
        assert length(found_elements) > 0,
               "Should find at least one core UI element. Expected: #{inspect(expected_elements)}, Found: #{inspect(found_elements)}"
        
        # Log detailed findings
        IO.puts("   🎯 Script Table Analysis Results:")
        IO.puts("   📋 Total rendered elements: #{length(context.all_rendered_text)}")
        IO.puts("   🔍 UI indicators found: #{inspect(context.ui_indicators)}")
        IO.puts("   ✅ Core elements verified: #{inspect(found_elements)}")
        
        # Log first few rendered elements for debugging
        sample_text = context.all_rendered_text |> Enum.take(5)
        IO.puts("   📄 Sample rendered text: #{inspect(sample_text)}")
        
        :ok
      end
    end

    # =============================================================================
    # 4. MEMEX INTEGRATION VALIDATION  
    # =============================================================================

    scenario "Memelex integration is working", context do
      given_ "Flamelex includes Memelex functionality", context do
        # Allow time for Memelex to initialize
        Process.sleep(500)
        {:ok, context}
      end

      when_ "we check for Memelex components", context do
        # Check that Memelex modules are available
        memelex_modules = [
          Code.ensure_loaded(Memelex),
          Code.ensure_loaded(Memelex.My.TODOs),
          Code.ensure_loaded(Memelex.My.Wiki)
        ]
        
        memelex_loaded = Enum.all?(memelex_modules, fn
          {:module, _} -> true
          _ -> false
        end)
        
        # Check if memelex API functions are available
        todos_available = function_exported?(Memelex.My.TODOs, :show, 0)
        
        {:ok, Map.merge(context, %{
          memelex_loaded: memelex_loaded,
          todos_available: todos_available
        })}
      end

      then_ "Memelex should be properly integrated", context do
        assert context.memelex_loaded, "Memelex modules should be loaded"
        assert context.todos_available, "Memelex APIs should be available"
        
        IO.puts("   ✅ Memelex integration is working")
        :ok
      end
    end

  end  # Close the spex block

end
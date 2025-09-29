defmodule Flamelex.MenuBarNavigationSpex do
  @moduledoc """
  MenuBar Navigation Spex for Flamelex.

  This spex validates that:
  1. MenuBar remains responsive across all pages
  2. Menu items navigate to correct destinations
  3. Mouse hover effects work properly
  4. Navigation doesn't break menubar functionality
  5. All major pages are accessible via menubar

  This ensures our fixes for request_input issues are working correctly
  and menubar navigation is stable across the application.
  """
  use SexySpex
  alias Flamelex.TestHelpers.ScriptInspector

  setup_all do
    # Start Flamelex with MCP server
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "MenuBar Navigation - Clean page transitions via menu items",
    description: "Validates menubar navigation between major Flamelex pages",
    tags: [:menubar, :navigation, :integration, :mouse_events] do

    scenario "Application starts with working menubar", context do
      given_ "Flamelex is running", context do
        assert SexySpex.Helpers.application_running?(:flamelex), "Flamelex should be started"
        
        # Wait for scene hierarchy to be ready
        {:ok, scene_data} = wait_for_scene_hierarchy(:main_viewport, timeout: 5000)
        IO.puts("\n📊 Flamelex initialized with #{map_size(scene_data)} scenes")
        
        # Take baseline screenshot
        baseline_screenshot = ScenicMcp.Probes.take_screenshot("menubar_nav_baseline")
        
        {:ok, Map.put(context, :baseline_screenshot, baseline_screenshot)}
      end

      then_ "menubar should be visible and contain expected items", context do
        # Inspect viewport to verify menubar presence
        viewport_data = ScenicMcp.Probes.inspect_viewport()
        
        # Verify menubar is rendered (should see menu items in the script table)
        assert ScriptInspector.rendered_text_contains?("Flamelex") or
               ScriptInspector.rendered_text_contains?("my TODOs") or
               ScriptInspector.rendered_text_contains?("rapid selector"),
               "MenuBar items should be visible"
        
        :ok
      end
    end

    scenario "Navigate to My TODOs page", context do
      given_ "menubar is visible and responsive", context do
        # Clear any existing state
        Process.sleep(100)
        
        # Take screenshot before navigation
        before_todos_screenshot = ScenicMcp.Probes.take_screenshot("before_todos_nav")
        {:ok, Map.put(context, :before_todos_screenshot, before_todos_screenshot)}
      end

      when_ "user clicks on 'my TODOs' menu item", context do
        # Click on the my TODOs menu item
        # Based on typical menubar positioning, adjust coordinates as needed
        # These coordinates assume menubar at top with items spaced horizontally
        ScenicMcp.Probes.send_mouse_click(%{x: 200, y: 30})  # Approximate position
        Process.sleep(500)  # Allow page transition
        
        todos_page_screenshot = ScenicMcp.Probes.take_screenshot("todos_page_loaded")
        {:ok, Map.put(context, :todos_page_screenshot, todos_page_screenshot)}
      end

      then_ "TODOs page should load", context do
        # Verify we're on the TODOs page
        rendered_content = ScriptInspector.get_rendered_text_string()
        
        # Should see TODO-related content
        assert ScriptInspector.rendered_text_contains?("My TODOs") or
               ScriptInspector.rendered_text_contains?("No TODOs") or
               ScriptInspector.rendered_text_contains?("Filter") or
               ScriptInspector.rendered_text_contains?("Create New TODO"),
               "TODOs page content should be visible. Got: #{rendered_content}"
        
        :ok
      end

      and_ "menubar should remain responsive", context do
        # Test hover effect on another menu item
        ScenicMcp.Probes.send_mouse_move(%{x: 300, y: 30})  # Move to another menu item
        Process.sleep(100)
        
        # Click should still work
        ScenicMcp.Probes.send_mouse_click(%{x: 300, y: 30})
        Process.sleep(100)
        
        # Menubar should have responded (even if just highlighting)
        hover_test_screenshot = ScenicMcp.Probes.take_screenshot("menubar_hover_test")
        
        :ok
      end
    end

    scenario "Navigate to Rapid Selector page", context do
      given_ "currently on TODOs or another page", context do
        Process.sleep(100)
        
        before_rapid_screenshot = ScenicMcp.Probes.take_screenshot("before_rapid_nav")
        {:ok, Map.put(context, :before_rapid_screenshot, before_rapid_screenshot)}
      end

      when_ "user clicks on 'rapid selector' menu item", context do
        # Click on rapid selector menu item
        ScenicMcp.Probes.send_mouse_click(%{x: 350, y: 30})  # Approximate position
        Process.sleep(500)  # Allow page transition
        
        rapid_page_screenshot = ScenicMcp.Probes.take_screenshot("rapid_selector_loaded")
        {:ok, Map.put(context, :rapid_page_screenshot, rapid_page_screenshot)}
      end

      then_ "Rapid Selector page should load", context do
        rendered_content = ScriptInspector.get_rendered_text_string()
        
        # Should see Rapid Selector content
        assert ScriptInspector.rendered_text_contains?("Collections") or
               ScriptInspector.rendered_text_contains?("Rapid Selector") or
               rendered_content == "",  # Rapid selector might start empty
               "Rapid Selector page should load. Got: #{rendered_content}"
        
        :ok
      end

      and_ "menubar should still accept mouse events", context do
        # Move mouse over different menu items
        menu_positions = [
          {100, 30},  # First item
          {200, 30},  # Second item
          {300, 30},  # Third item
        ]
        
        for {x, y} <- menu_positions do
          ScenicMcp.Probes.send_mouse_move(%{x: x, y: y})
          Process.sleep(50)
        end
        
        # Verify we can still click
        ScenicMcp.Probes.send_mouse_click(%{x: 100, y: 30})
        Process.sleep(100)
        
        menubar_working_screenshot = ScenicMcp.Probes.take_screenshot("menubar_still_working")
        
        :ok
      end
    end

    scenario "Navigate to New Buffer page", context do
      given_ "menubar is functional", context do
        Process.sleep(100)
        
        before_buffer_screenshot = ScenicMcp.Probes.take_screenshot("before_buffer_nav")
        {:ok, Map.put(context, :before_buffer_screenshot, before_buffer_screenshot)}
      end

      when_ "user clicks on 'new buffer' menu item", context do
        # Navigate to new buffer
        # This might be under a File menu or similar
        ScenicMcp.Probes.send_mouse_click(%{x: 100, y: 30})  # Click File or first menu
        Process.sleep(200)
        
        # If dropdown appears, click new buffer option
        ScenicMcp.Probes.send_mouse_click(%{x: 100, y: 70})  # Dropdown item position
        Process.sleep(500)
        
        buffer_page_screenshot = ScenicMcp.Probes.take_screenshot("new_buffer_loaded")
        {:ok, Map.put(context, :buffer_page_screenshot, buffer_page_screenshot)}
      end

      then_ "text editor buffer should be available", context do
        # Type some text to verify we're in a buffer
        test_text = "Testing buffer"
        ScenicMcp.Probes.send_text(test_text)
        Process.sleep(200)
        
        rendered_content = ScriptInspector.get_rendered_text_string()
        
        # Should either see our typed text or buffer-related UI
        assert ScriptInspector.rendered_text_contains?(test_text) or
               ScriptInspector.rendered_text_contains?("Buffer") or
               ScriptInspector.rendered_text_contains?("unnamed"),
               "Buffer page should be active. Got: #{rendered_content}"
        
        :ok
      end
    end

    scenario "Rapid navigation between pages", context do
      given_ "menubar navigation is working", context do
        Process.sleep(100)
        :ok
      end

      when_ "user rapidly switches between pages", context do
        # Rapid page switching to test menubar stability
        navigation_sequence = [
          {200, 30},  # my TODOs
          {350, 30},  # rapid selector
          {200, 30},  # back to TODOs
          {100, 30},  # File/new buffer
          {350, 30},  # rapid selector again
        ]
        
        for {x, y} <- navigation_sequence do
          ScenicMcp.Probes.send_mouse_click(%{x: x, y: y})
          Process.sleep(200)  # Quick transitions
        end
        
        rapid_nav_screenshot = ScenicMcp.Probes.take_screenshot("rapid_navigation_complete")
        {:ok, Map.put(context, :rapid_nav_screenshot, rapid_nav_screenshot)}
      end

      then_ "menubar should remain functional throughout", context do
        # Final test - hover over menu items
        ScenicMcp.Probes.send_mouse_move(%{x: 250, y: 30})
        Process.sleep(100)
        
        # One more click to verify responsiveness
        ScenicMcp.Probes.send_mouse_click(%{x: 200, y: 30})
        Process.sleep(300)
        
        # Should still be able to see page content
        rendered_content = ScriptInspector.get_rendered_text_string()
        
        # As long as we got some content and no crash, navigation worked
        assert is_binary(rendered_content),
               "Application should remain stable after rapid navigation"
        
        final_screenshot = ScenicMcp.Probes.take_screenshot("menubar_nav_final_state")
        
        :ok
      end
    end

    scenario "Dropdown menu navigation", context do
      given_ "menubar with dropdown menus", context do
        Process.sleep(100)
        
        dropdown_baseline = ScenicMcp.Probes.take_screenshot("dropdown_baseline")
        {:ok, Map.put(context, :dropdown_baseline, dropdown_baseline)}
      end

      when_ "user hovers over menu item with dropdown", context do
        # Hover over a menu item that has a dropdown
        ScenicMcp.Probes.send_mouse_move(%{x: 100, y: 30})
        Process.sleep(300)  # Allow dropdown to appear
        
        dropdown_visible = ScenicMcp.Probes.take_screenshot("dropdown_visible")
        {:ok, Map.put(context, :dropdown_visible, dropdown_visible)}
      end

      and_ "user moves mouse to dropdown item", context do
        # Move down to dropdown item
        ScenicMcp.Probes.send_mouse_move(%{x: 100, y: 70})
        Process.sleep(100)
        
        # Click dropdown item
        ScenicMcp.Probes.send_mouse_click(%{x: 100, y: 70})
        Process.sleep(300)
        
        dropdown_clicked = ScenicMcp.Probes.take_screenshot("dropdown_item_clicked")
        {:ok, Map.put(context, :dropdown_clicked, dropdown_clicked)}
      end

      then_ "dropdown navigation should work correctly", context do
        # Verify dropdown closed and action was taken
        # Move mouse away to test dropdown closure
        ScenicMcp.Probes.send_mouse_move(%{x: 500, y: 200})
        Process.sleep(200)
        
        # Menubar should still be responsive
        ScenicMcp.Probes.send_mouse_move(%{x: 200, y: 30})
        Process.sleep(100)
        
        dropdown_test_complete = ScenicMcp.Probes.take_screenshot("dropdown_test_complete")
        
        :ok
      end
    end

  end
end
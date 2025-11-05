defmodule Flamelex.MenuBarBasicNavigationSpex do
  @moduledoc """
  Basic MenuBar Navigation Spex for Flamelex.
  
  This is a simpler, more focused version that tests core menubar navigation
  functionality using the MenuBarInspector helper.
  
  Tests:
  1. Navigate to My TODOs
  2. Navigate to Rapid Selector  
  3. Verify menubar stays responsive
  """
  use SexySpex
  alias Flamelex.TestHelpers.{ScriptInspector, MenuBarInspector}

  setup_all do
    # Start Flamelex with MCP server
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Basic MenuBar Navigation - Core page transitions",
    description: "Validates basic menubar navigation works after input handling fixes",
    tags: [:menubar, :navigation, :core] do

    scenario "Navigate to My TODOs via menubar", context do
      given_ "Flamelex is running with menubar visible", context do
        assert SexySpex.Helpers.application_running?(:flamelex), "Flamelex should be started"
        
        # Wait for initialization
        Process.sleep(1000)
        
        # Verify menubar is responsive
        MenuBarInspector.verify_menubar_responsive()
        
        {:ok, context}
      end

      when_ "user clicks on My TODOs menu item", context do
        # Click on My TODOs
        MenuBarInspector.click_menu_item("my todos")
        
        # Wait for page transition
        Process.sleep(500)
        
        {:ok, context}
      end

      then_ "TODOs page should load", context do
        # Wait for page content
        assert MenuBarInspector.wait_for_page(:todos, timeout: 2000),
               "TODOs page should load with expected content"
        
        :ok
      end
      
      and_ "menubar should remain clickable", context do
        # Test that menubar still responds
        MenuBarInspector.hover_menu_item("rapid selector")
        Process.sleep(100)
        
        # Should be able to navigate elsewhere
        # Screenshot removed - not available in test environment
        
        :ok
      end
    end

    scenario "Navigate to Rapid Selector", context do
      given_ "currently on TODOs page", context do
        # We're already on TODOs from previous scenario
        Process.sleep(100)
        :ok
      end

      when_ "user clicks on Rapid Selector menu item", context do
        MenuBarInspector.click_menu_item("rapid selector")
        
        # Wait for transition
        Process.sleep(500)
        
        # Screenshot removed - not available in test environment
        {:ok, context}
      end

      then_ "Rapid Selector page should load", context do
        # Check for rapid selector content
        assert MenuBarInspector.wait_for_page(:rapid_selector, timeout: 2000),
               "Rapid Selector page should load"
        
        :ok
      end
      
      and_ "menubar hover effects should work", context do
        # Test hover on multiple items
        items = ["flamelex", "my todos", "memex"]
        
        for item <- items do
          MenuBarInspector.hover_menu_item(item)
          Process.sleep(100)
        end
        
        # Screenshot removed - not available in test environment
        
        :ok
      end
    end

    scenario "Round-trip navigation", context do
      given_ "ability to navigate between pages", context do
        Process.sleep(100)
        :ok
      end

      when_ "user navigates back to TODOs then to Rapid Selector again", context do
        # Back to TODOs
        MenuBarInspector.click_menu_item("my todos")
        Process.sleep(500)
        
        # Verify we're on TODOs
        assert MenuBarInspector.wait_for_page(:todos, timeout: 1000)
        
        # Back to Rapid Selector
        MenuBarInspector.click_menu_item("rapid selector")
        Process.sleep(500)
        
        # Screenshot removed - not available in test environment
        {:ok, context}
      end

      then_ "navigation should work in both directions", context do
        # Verify we're back on Rapid Selector
        assert MenuBarInspector.wait_for_page(:rapid_selector, timeout: 1000),
               "Should be able to navigate back to Rapid Selector"
        
        :ok
      end
      
      and_ "menubar should remain fully functional", context do
        # Final responsiveness check
        MenuBarInspector.verify_menubar_responsive()
        
        # One more navigation to prove it works
        MenuBarInspector.click_menu_item("my todos")
        Process.sleep(300)
        
        # Screenshot removed - not available in test environment
        
        :ok
      end
    end

  end
end
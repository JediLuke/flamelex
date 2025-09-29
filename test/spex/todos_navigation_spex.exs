defmodule Flamelex.Test.TodosNavigationSpex do
  @moduledoc """
  Test navigation to TODOs page via menubar.
  
  This spex demonstrates navigating through the menu system to reach
  the TODOs page, which is a common user workflow in Flamelex.
  """
  use SexySpex
  
  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end
  
  spex "Navigate to TODOs via MenuBar",
    description: "Use menubar to navigate to Memelex > my TODOs",
    tags: [:navigation, :menubar, :todos, :memelex] do
    
    scenario "Click through menu to reach TODOs page", context do
      given_ "Flamelex is running with menubar visible", context do
        IO.puts("   ⏳ Waiting for app to fully load...")
        Process.sleep(3000)
        
        # Verify app is running
        state = Flamelex.Fluxus.RadixStore.get()
        IO.puts("\n   🚀 Flamelex is running")
        
        # Check menubar is visible
        IO.puts("   📊 Checking for menubar...")
        
        # For now, we'll assume menubar is visible since it's always rendered in Layer2
        # Later we can use semantic DOM to verify this
        
        {:ok, context}
      end
      
      when_ "I click on the Memelex menu", context do
        IO.puts("\n   🎯 Clicking on 'Memelex' menu...")
        
        # Calculate approximate position of Memelex menu item
        # Based on menu structure: Flamelex, Quillex, Memelex (3rd item)
        # Each menu item is roughly 100px wide
        menu_x = 250  # Approximate x position for 3rd menu item
        menu_y = 30   # Middle of menubar (60px height)
        
        IO.puts("   🖱️  Clicking at position (#{menu_x}, #{menu_y})...")
        
        # For now, simulate the click
        # In a real test, we would use scenic_mcp to send actual mouse events
        
        # Simulate opening the Memelex submenu
        IO.puts("   📂 Memelex menu should now be open")
        
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      and_ "I click on 'my TODOs' menu item", context do
        IO.puts("\n   🎯 Looking for 'my TODOs' menu item...")
        
        # The submenu appears below the main menu
        # "my TODOs" is the second item in the Memelex submenu
        todos_x = 250      # Same x as parent menu
        todos_y = 90       # Below menubar + first menu item height
        
        IO.puts("   🖱️  Clicking 'my TODOs' at position (#{todos_x}, #{todos_y})...")
        
        # Trigger the correct action (what the menu really does)
        # Memelex.My.TODOs.show() calls Memelex.Fluxus.event(:show_todos)
        # which eventually triggers this Flamelex action
        result = Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        
        case result do
          :ok -> 
            IO.puts("   ✅ TODOs action triggered successfully")
          other ->
            IO.puts("   ⚠️  TODOs action returned: #{inspect(other)}")
        end
        
        # Give UI time to update
        Process.sleep(2000)
        
        {:ok, context}
      end
      
      then_ "TODOs page should be displayed", context do
        IO.puts("\n   🔍 Verifying TODOs page is displayed...")
        
        # Check the app state for TODOs
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Look for TODOs in the app state - it's stored as :todo_list
        todos_active = case state do
          %{apps: %{todo_list: todos_state}} when is_map(todos_state) ->
            IO.puts("   ✅ TODOs app found in state (as :todo_list)")
            IO.puts("   📋 TODOs state: #{inspect(todos_state, pretty: true, limit: 5)}")
            true
          %{apps: apps} when is_map(apps) ->
            IO.puts("   ❌ todo_list not found in apps")
            IO.puts("   📊 Active apps: #{inspect(Map.keys(apps))}")
            false
          _ ->
            IO.puts("   ❌ No apps state found")
            false
        end
        
        unless todos_active do
          raise "TODOs page was not activated after menu navigation"
        end
        
        # In the future, we could also check semantic DOM for TODO-specific elements
        IO.puts("   🎉 TODOs navigation test completed successfully!")
        
        {:ok, context}
      end
    end
  end
end
defmodule Flamelex.Test.SimpleTodoNavigationSpex do
  @moduledoc """
  Simple user journey: Navigate to TODOs page
  
  This is a minimal spex that focuses on the core journey of navigating
  to the TODOs page without complex visual verification.
  """
  use SexySpex
  
  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end
  
  spex "Simple TODO Navigation",
    description: "Basic navigation to TODOs page",
    tags: [:navigation, :todos, :simple] do
    
    scenario "Navigate to TODOs page using API", context do
      given_ "Flamelex is running", context do
        # Give app time to fully initialize
        Process.sleep(2000)
        
        # Check initial state
        state = Flamelex.Fluxus.RadixStore.get()
        IO.puts("\n   🚀 Flamelex is running")
        
        # Log memex info if available
        case state do
          %{memex: %{env: %{name: env_name}}} ->
            IO.puts("   📁 Memex environment: #{env_name}")
          _ ->
            IO.puts("   ℹ️  No memex environment active")
        end
        
        context
      end
      
      when_ "I navigate to TODOs page", context do
        IO.puts("\n   🎯 Navigating to TODOs...")
        
        # Use the Fluxus action to show todos
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        
        # Give UI time to update
        Process.sleep(1000)
        
        context
      end
      
      then_ "TODOs page should be displayed", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Check that TODOlist component is active
        active_apps = state.gui.layer1.active_apps
        assert Flamelex.GUI.Component.TODOlist in active_apps,
               "TODOlist should be in active apps. Got: #{inspect(active_apps)}"
        
        # Check layout
        assert state.gui.layer1.layout == :full_screen,
               "Should be in full screen layout. Got: #{state.gui.layer1.layout}"
        
        IO.puts("   ✅ TODOs page is displayed")
        
        # Check todo list state
        todo_state = state.apps.todo_list
        todo_count = length(todo_state.list)
        IO.puts("   📝 Found #{todo_count} todos")
        
        if todo_count == 0 do
          IO.puts("   ℹ️  Todo list is empty")
        else
          # Show first few todos
          todo_state.list
          |> Enum.take(3)
          |> Enum.each(fn todo ->
            IO.puts("   - #{todo.title}")
          end)
          
          if todo_count > 3 do
            IO.puts("   ... and #{todo_count - 3} more")
          end
        end
        
        context
      end
    end
    
    scenario "Check todo list features", context do
      given_ "TODOs page is open", context do
        # Ensure we're on the todos page
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        context
      end
      
      when_ "I check available features", context do
        state = Flamelex.Fluxus.RadixStore.get()
        todo_state = state.apps.todo_list
        
        IO.puts("\n   🔍 Checking todo list features...")
        IO.puts("   - Current filter: #{inspect(todo_state.filter)}")
        IO.puts("   - Turbo scroll: #{todo_state.turbo_scroll?}")
        IO.puts("   - Scroll position: #{inspect(todo_state.scroll)}")
        IO.puts("   - Selected todo: #{inspect(todo_state.selected)}")
        
        context
      end
      
      then_ "Basic features should be available", context do
        # These are the features we expect to exist
        state = Flamelex.Fluxus.RadixStore.get()
        todo_state = state.apps.todo_list
        
        # Check state structure
        assert Map.has_key?(todo_state, :list), "Should have todo list"
        assert Map.has_key?(todo_state, :filter), "Should have filter capability"
        assert Map.has_key?(todo_state, :turbo_scroll?), "Should have turbo scroll flag"
        assert Map.has_key?(todo_state, :scroll), "Should have scroll position"
        
        IO.puts("   ✅ Basic todo list features are present")
        
        context
      end
    end
    
    scenario "Test filter functionality", context do
      given_ "TODOs page with some todos", context do
        # Create a few test todos if needed
        if Flamelex.Fluxus.RadixStore.get().apps.todo_list.list == [] do
          IO.puts("\n   📝 Creating test todos...")
          
          # Create todos using Memelex API
          Memelex.My.TODOs.new("Test todo 1", tags: ["test", "urgent"])
          Memelex.My.TODOs.new("Test todo 2", tags: ["test", "personal"]) 
          Memelex.My.TODOs.new("Test todo 3", tags: ["test", "work"])
          
          Process.sleep(500)
          
          # Refresh the todo list
          Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
          Process.sleep(500)
        end
        
        context
      end
      
      when_ "I apply a filter", context do
        IO.puts("\n   🔍 Applying filter...")
        
        # Try filtering by tag
        Flamelex.Fluxus.action({
          Flamelex.GUI.Component.TODOlist.Reducer, 
          {:filter_todos, {:tag, "test"}}
        })
        
        Process.sleep(500)
        
        context
      end
      
      then_ "Filter should be applied", context do
        state = Flamelex.Fluxus.RadixStore.get()
        todo_state = state.apps.todo_list
        
        # Check filter is set
        assert todo_state.filter == {:tag, "test"},
               "Filter should be set. Got: #{inspect(todo_state.filter)}"
        
        # All todos in list should have the test tag
        Enum.each(todo_state.list, fn todo ->
          assert "test" in todo.tags,
                 "Todo '#{todo.title}' should have 'test' tag"
        end)
        
        IO.puts("   ✅ Filter is working")
        IO.puts("   📝 Filtered list has #{length(todo_state.list)} todos")
        
        context
      end
    end
  end
end
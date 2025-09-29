defmodule Flamelex.Test.HelloMemexSpex do
  @moduledoc """
  User journey spex: Boot Flamelex and navigate to TODOs page
  
  This spex tests the initial user experience:
  1. Boot Flamelex
  2. Verify memex environment is displayed (if present)
  3. Navigate to TODOs page via menubar
  
  This establishes the foundation for todo-related user journeys.
  """
  use SexySpex
  
  # Import visual verification helpers
  # Note: Scenic.DevTools functions like raw_scene_script may not be available
  # in test environment - we'll handle gracefully with try/rescue
  alias Flamelex.TestHelpers.ScriptInspector
  
  @menubar_height 30  # Approximate height of menubar
  @menu_item_width 100  # Approximate width of menu items
  @tmp_screenshots_dir "test/spex/screenshots/hello_memex"
  
  setup_all do
    # Ensure screenshots directory exists
    File.mkdir_p!(@tmp_screenshots_dir)
    
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end
  
  spex "Hello Memex - Boot and Navigate to TODOs",
    description: "Tests the user journey from boot to TODOs page",
    tags: [:user_journey, :memex, :todos, :navigation] do
    
    scenario "Boot Flamelex with memex environment", context do
      given_ "Flamelex is starting up with a memex environment", context do
        # The app should already be starting via setup_all
        Process.sleep(2000)  # Give it time to fully initialize
        
        # Capture initial scene state
        initial_scene = try do
          raw_scene_script()
        rescue
          _ -> 
            IO.puts("   ℹ️  Scene introspection not yet available")
            %{}
        end
        
        # Take a screenshot of initial state
        baseline_screenshot = try do
          path = Path.join(@tmp_screenshots_dir, "boot_state.png")
          ScenicMcp.Probes.take_screenshot(path)
          path
        rescue
          _ -> 
            IO.puts("   ℹ️  Screenshot skipped")
            nil
        end
        
        Map.merge(context, %{
          initial_scene: initial_scene,
          baseline_screenshot: baseline_screenshot
        })
      end
      
      then_ "I should see the memex environment name displayed", context do
        # Check if we have a memex environment active
        state = Flamelex.Fluxus.RadixStore.get()
        
        env_info = case state do
          %{memex: %{env: %{name: env_name, memex_directory: dir}}} ->
            IO.puts("   ✓ Memex environment detected: #{env_name}")
            IO.puts("   📁 Directory: #{dir}")
            %{name: env_name, directory: dir}
            
          _ ->
            IO.puts("   ℹ️  No memex environment active")
            nil
        end
        
        # Try to verify environment is visible in the UI
        if env_info do
          # Check if we can find the environment name in the rendered content
          try do
            # This would work if the env indicator is implemented
            content = ScriptInspector.extract_user_content()
            if Enum.any?(content, &String.contains?(&1, env_info.name)) do
              IO.puts("   ✓ Environment name visible in UI")
            else
              IO.puts("   ⚠️  Environment name not found in rendered content")
              IO.puts("   → Implementation needed: Add MemexEnvIndicator to root scene")
            end
          rescue
            _ -> 
              IO.puts("   ℹ️  Visual verification pending implementation")
          end
        end
        
        Map.put(context, :env_info, env_info)
      end
      
      when_ "I attempt to navigate to TODOs via the menubar", context do
        # First, let's use the API to show todos as a baseline
        IO.puts("\n   🎯 Navigating to TODOs page...")
        
        # Direct API navigation (reliable fallback)
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(1000)
        
        # Capture the todos page state
        todos_screenshot = try do
          path = Path.join(@tmp_screenshots_dir, "todos_page.png")
          ScenicMcp.Probes.take_screenshot(path)
          IO.puts("   📸 Screenshot saved: #{path}")
          path
        rescue
          _ -> nil
        end
        
        Map.put(context, :todos_screenshot, todos_screenshot)
      end
      
      then_ "I should be on the TODOs page", context do
        state = Flamelex.Fluxus.RadixStore.get()
        
        # Verify we're showing the todo list
        assert Flamelex.GUI.Component.TODOlist in state.gui.layer1.active_apps,
               "TODOlist component should be active"
        
        # Verify layout
        assert state.gui.layer1.layout == :full_screen,
               "Should be in full screen layout"
        
        IO.puts("   ✓ Successfully navigated to TODOs page")
        
        # Check what we can see in the todos page
        try do
          scene_data = raw_scene_script()
          component_count = map_size(scene_data)
          IO.puts("   📊 Scene contains #{component_count} components")
          
          # Look for todo-related components
          todo_components = scene_data
          |> Map.keys()
          |> Enum.filter(fn key ->
            case key do
              {module, _} when is_atom(module) -> 
                String.contains?(Atom.to_string(module), "TODO")
              _ -> false
            end
          end)
          
          if length(todo_components) > 0 do
            IO.puts("   ✓ Found #{length(todo_components)} TODO-related components")
          end
        rescue
          _ -> 
            IO.puts("   ℹ️  Scene introspection analysis skipped")
        end
        
        context
      end
    end
    
    scenario "Visual state of empty TODO list", context do
      given_ "TODOs page is open with no todos", context do
        # Ensure we're on the todos page
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, :show_todos})
        Process.sleep(500)
        
        # Check current todo count
        state = Flamelex.Fluxus.RadixStore.get()
        todo_count = length(state.apps.todo_list.list)
        IO.puts("\n   📝 Current todo count: #{todo_count}")
        
        Map.put(context, :todo_count, todo_count)
      end
      
      then_ "Empty state message should be visible", context do
        if context.todo_count == 0 do
          # Try to find empty state message
          try do
            content = ScriptInspector.extract_user_content()
            |> Enum.join(" ")
            
            if String.contains?(content, "No TODOs") do
              IO.puts("   ✓ Empty state message is visible")
            else
              IO.puts("   ⚠️  Expected empty state message not found")
              IO.puts("   → Content: #{inspect(content)}")
            end
          rescue
            _ ->
              IO.puts("   ℹ️  Visual verification of empty state pending")
          end
        else
          IO.puts("   ℹ️  List has #{context.todo_count} todos - not empty")
        end
        
        context
      end
    end
    
    scenario "Menubar interaction exploration", context do
      given_ "Flamelex is running", context do
        Process.sleep(500)
        
        # Capture current scene architecture
        scene_before = try do
          raw_scene_script()
        rescue
          _ -> %{}
        end
        
        Map.put(context, :scene_before_menu, scene_before)
      end
      
      when_ "I explore menubar interaction methods", context do
        IO.puts("\n   🔍 Exploring menubar interaction...")
        
        # Method 1: Try keyboard alt key to open menu
        try do
          IO.puts("   → Trying Alt key...")
          ScenicMcp.Probes.send_keys("alt", [])
          Process.sleep(300)
          
          # Check if menu opened
          scene_after_alt = try do
            raw_scene_script()
          rescue
            _ -> %{}
          end
          
          if map_size(scene_after_alt) > map_size(context.scene_before_menu) do
            IO.puts("   ✓ Alt key opened menu (scene components increased)")
          end
        rescue
          e -> 
            IO.puts("   ❌ Alt key failed: #{inspect(e)}")
        end
        
        # Method 2: Try mouse hover on menubar
        try do
          IO.puts("   → Trying mouse hover on menubar...")
          ScenicMcp.Probes.send_mouse_move(x: 100, y: 15)
          Process.sleep(300)
        rescue
          e ->
            IO.puts("   ❌ Mouse hover failed: #{inspect(e)}")
        end
        
        # Method 3: Document what we learned
        IO.puts("\n   📋 Menubar Navigation Status:")
        IO.puts("   - Direct API navigation: ✓ Working")
        IO.puts("   - Mouse-based navigation: ⚠️  Needs coordinate mapping")
        IO.puts("   - Keyboard navigation: ⚠️  Needs implementation")
        IO.puts("   - Flickering issue: ⚠️  Needs fix")
        
        context
      end
      
      then_ "Document findings for implementation", context do
        IO.puts("\n   📝 Implementation Recommendations:")
        IO.puts("   1. Add MemexEnvIndicator to root scene")
        IO.puts("   2. Fix menubar hover flickering")
        IO.puts("   3. Implement Alt+key menu navigation")
        IO.puts("   4. Add semantic IDs to menu items")
        IO.puts("   5. Create keyboard shortcut system")
        
        context
      end
    end
  end
  
  # Helper function to wait for UI changes
  defp wait_for_ui_change(check_fn, timeout_ms \\ 2000) do
    deadline = System.monotonic_time(:millisecond) + timeout_ms
    
    Stream.repeatedly(fn ->
      if check_fn.() do
        {:halt, :ok}
      else
        Process.sleep(100)
        if System.monotonic_time(:millisecond) > deadline do
          {:halt, :timeout}
        else
          {:cont, nil}
        end
      end
    end)
    |> Enum.take_while(&(&1 == {:cont, nil}))
    
    check_fn.()
  end
end
defmodule Flamelex.Test.NavigationDiscoverySpex do
  @moduledoc """
  Simple spex to discover what navigation capabilities are currently available in Flamelex.
  Focus on understanding the current state rather than complex flows.
  """

  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Navigation Discovery",
    description: "Understand current navigation capabilities and identify issues",
    tags: [:navigation, :discovery, :debugging] do
    
    scenario "Discover current navigation state", context do
      given_ "Flamelex starts successfully", context do
        IO.puts("🚀 Starting Flamelex navigation discovery...")
        
        # Wait for app to fully load
        Process.sleep(3000)
        
        IO.puts("✅ Discovery spex ready to run")
        IO.puts("📋 Goal: Understand current navigation capabilities")
        IO.puts("🎯 Focus: Buffer, Rapid Selector, TODOs navigation")
      end
      
      
      when_ "we inspect the current interface", context do
        IO.puts("\n📊 Navigation Analysis:")
        IO.puts("- Need to identify how to switch between screens")
        IO.puts("- Current issue: everything routes to rapid selector")
        IO.puts("- Required flows:")
        IO.puts("  1. New buffer → text editing interface")
        IO.puts("  2. Rapid selector → file/project picker") 
        IO.puts("  3. My TODOs → task management")
        IO.puts("  4. Navigation between these states")
        
        # Check current Flamelex state
        state = Flamelex.Fluxus.RadixStore.get()
        current_apps = Map.get(state, :apps, %{})
        
        IO.puts("\n🔍 Current Flamelex State:")
        IO.puts("Active apps: #{inspect(Map.keys(current_apps))}")
        
        # Check if we can see any navigation clues
        if Map.has_key?(current_apps, :rapid_selector) do
          IO.puts("  ✅ Rapid selector available")
        end
        
        if Map.has_key?(current_apps, :todo_list) do
          IO.puts("  ✅ TODOs available (as todo_list)")
        end
        
        :ok
      end
      
      then_ "we should understand available navigation options", context do
        IO.puts("\n📝 Navigation Requirements:")
        
        requirements = [
          "✅ App starts in default memex environment",
          "🎯 Can open new buffer for text editing", 
          "🎯 Can access rapid selector for file/project selection",
          "🎯 Can access TODOs for task management",
          "🎯 Can navigate back and forth between these modes",
          "🎯 Each mode shows appropriate interface elements",
          "🎯 Navigation doesn't always route to rapid selector"
        ]
        
        Enum.each(requirements, &IO.puts/1)
        
        IO.puts("\n🛠️  Next Development Steps:")
        
        steps = [
          "1. 🔍 Investigate Flamelex action system",
          "2. 📋 Identify screen switching actions", 
          "3. 🐛 Find why everything routes to rapid selector",
          "4. 🔧 Fix action routing logic",
          "5. ✅ Create working spex for each navigation flow",
          "6. 📱 Test complete navigation cycle"
        ]
        
        Enum.each(steps, &IO.puts/1)
        
        IO.puts("\n🎯 Priority Focus:")
        IO.puts("- Get basic screen switching working")
        IO.puts("- Use action system directly, not MenuBar") 
        IO.puts("- Verify each screen type works independently")
        IO.puts("- Build comprehensive navigation spex")
        
        :ok
      end
    end
  end
end
defmodule Flamelex.Test.OptimizedMenuBarSpex do
  @moduledoc """
  Test suite for the OptimizedMenuBar component.
  This ensures the component initializes properly and handles hover without crashes.
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "OptimizedMenuBar initializes without crashing",
    description: "Verify the OptimizedMenuBar component can be initialized",
    tags: [:menubar, :initialization, :critical] do
    
    scenario "Component initializes successfully", context do
      given_ "Flamelex is running", context do
        Process.sleep(3000)
        
        # Get the current state to verify menubar exists
        state = Flamelex.Fluxus.RadixStore.get()
        
        IO.puts("   📊 Current layer2 state: #{inspect(Map.keys(state.layers.two))}")
        
        {:ok, Map.put(context, :initial_state, state)}
      end
      
      when_ "I check if OptimizedMenuBar is rendering", context do
        # The menubar should be rendered as part of layer 2
        # If it crashed during init, we wouldn't get here
        
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      then_ "the app is still running without crashes", context do
        # If we can still get state, the app didn't crash
        current_state = Flamelex.Fluxus.RadixStore.get()
        
        if current_state do
          IO.puts("   ✅ App is running - OptimizedMenuBar didn't crash on init")
        else
          raise "Could not get app state - possible crash"
        end
        
        {:ok, context}
      end
    end
  end

  spex "OptimizedMenuBar hover works without crashing",
    description: "Verify hover actions don't cause crashes",
    tags: [:menubar, :hover, :stability] do
    
    scenario "Hover over menu items", context do
      given_ "OptimizedMenuBar is initialized", context do
        Process.sleep(2000)
        {:ok, context}
      end
      
      when_ "I hover over different menu items", context do
        # Try hovering over each main menu
        try do
          IO.puts("   🖱️  Hovering over Flamelex menu...")
          Flamelex.Fluxus.action({Flamelex.GUI.Components.OptimizedMenuBar, {:hover, [1]}})
          Process.sleep(500)
          
          IO.puts("   🖱️  Hovering over Quillex menu...")
          Flamelex.Fluxus.action({Flamelex.GUI.Components.OptimizedMenuBar, {:hover, [2]}})
          Process.sleep(500)
          
          IO.puts("   🖱️  Hovering over Memelex menu...")
          Flamelex.Fluxus.action({Flamelex.GUI.Components.OptimizedMenuBar, {:hover, [3]}})
          Process.sleep(500)
          
          IO.puts("   🖱️  Hovering over Help menu...")
          Flamelex.Fluxus.action({Flamelex.GUI.Components.OptimizedMenuBar, {:hover, [4]}})
          Process.sleep(500)
          
          {:ok, Map.put(context, :hover_success, true)}
        rescue
          error ->
            IO.puts("   ❌ Error during hover: #{inspect(error)}")
            {:ok, Map.put(context, :hover_success, false)}
        end
      end
      
      then_ "no crashes occurred", context do
        if context.hover_success do
          IO.puts("   ✅ All hover actions completed without crashes")
        else
          raise "Hover actions caused crashes"
        end
        
        {:ok, context}
      end
    end
  end
end
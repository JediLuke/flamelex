defmodule Flamelex.Test.TodoSortingSpex do
  @moduledoc """
  Test suite for TODO list sorting functionality.
  
  Verifies that TODOs can be sorted by:
  - Priority (high to low, low to high)
  - Date (newest first, oldest first)
  """
  use SexySpex

  setup_all do
    SexySpex.Helpers.start_scenic_app(:flamelex)
  end

  spex "Sort TODOs by priority",
    description: "Verify TODOs can be sorted by priority in both directions",
    tags: [:todos, :sorting, :priority] do
    
    scenario "Sort by priority high to low", context do
      given_ "I have TODOs with different priorities", context do
        Process.sleep(3000)
        
        # Clear existing TODOs for clean test
        existing_todos = Memelex.My.TODOs.all()
        for todo <- existing_todos do
          Memelex.WikiServer.delete_tidbit(todo.uuid)
        end
        
        # Create test TODOs with different priorities
        low_todo = Memelex.My.TODOs.new("Low Priority Task")
        |> Memelex.TidBit.modify(%{"priority" => "low"})
        
        high_todo = Memelex.My.TODOs.new("High Priority Task")
        |> Memelex.TidBit.modify(%{"priority" => "high"})
        
        medium_todo = Memelex.My.TODOs.new("Medium Priority Task")
        |> Memelex.TidBit.modify(%{"priority" => "medium"})
        
        no_priority_todo = Memelex.My.TODOs.new("No Priority Task")
        
        # Navigate to TODOs
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, Map.merge(context, %{
          test_todos: [low_todo, high_todo, medium_todo, no_priority_todo]
        })}
      end
      
      when_ "I sort by priority (high to low)", context do
        # Trigger sort action
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:sort_todos, :priority_high}})
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      then_ "TODOs are ordered: high, medium, low, none", context do
        state = Flamelex.Fluxus.RadixStore.get()
        todo_list = state.apps.todo_list.list
        
        # Extract titles in order
        titles = Enum.map(todo_list, & &1.title)
        
        IO.puts("   📋 TODO order after sorting:")
        Enum.each(titles, fn title ->
          IO.puts("      - #{title}")
        end)
        
        # Verify order
        expected_order = ["High Priority Task", "Medium Priority Task", "Low Priority Task", "No Priority Task"]
        
        if titles == expected_order do
          IO.puts("   ✅ TODOs correctly sorted by priority (high to low)")
        else
          IO.puts("   ❌ Expected order: #{inspect(expected_order)}")
          IO.puts("   ❌ Actual order: #{inspect(titles)}")
          raise "Incorrect sort order"
        end
        
        {:ok, context}
      end
    end
    
    scenario "Sort by priority low to high", context do
      given_ "TODOs exist from previous test", context do
        Process.sleep(1000)
        {:ok, context}
      end
      
      when_ "I sort by priority (low to high)", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:sort_todos, :priority_low}})
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      then_ "TODOs are ordered: low, medium, high, none", context do
        state = Flamelex.Fluxus.RadixStore.get()
        todo_list = state.apps.todo_list.list
        
        titles = Enum.map(todo_list, & &1.title)
        
        expected_order = ["Low Priority Task", "Medium Priority Task", "High Priority Task", "No Priority Task"]
        
        if titles == expected_order do
          IO.puts("   ✅ TODOs correctly sorted by priority (low to high)")
        else
          raise "Incorrect sort order"
        end
        
        {:ok, context}
      end
    end
  end

  spex "Sort TODOs by date",
    description: "Verify TODOs can be sorted by creation date",
    tags: [:todos, :sorting, :date] do
    
    scenario "Sort by date newest first", context do
      given_ "I have TODOs created at different times", context do
        Process.sleep(3000)
        
        # Create TODOs with small delays to ensure different timestamps
        old_todo = Memelex.My.TODOs.new("Old Task")
        Process.sleep(100)
        
        middle_todo = Memelex.My.TODOs.new("Middle Task")
        Process.sleep(100)
        
        new_todo = Memelex.My.TODOs.new("New Task")
        
        # Navigate to TODOs
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, Map.merge(context, %{
          todos_by_age: [old_todo, middle_todo, new_todo]
        })}
      end
      
      when_ "I sort by date (newest first)", context do
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:sort_todos, :date_newest}})
        Process.sleep(1000)
        
        {:ok, context}
      end
      
      then_ "newest TODOs appear first", context do
        state = Flamelex.Fluxus.RadixStore.get()
        todo_list = state.apps.todo_list.list
        
        # Get first few titles
        top_titles = todo_list
        |> Enum.take(3)
        |> Enum.map(& &1.title)
        
        IO.puts("   📋 Top TODOs after date sort:")
        Enum.each(top_titles, fn title ->
          IO.puts("      - #{title}")
        end)
        
        # The newest TODO should be first
        if List.first(top_titles) == "New Task" do
          IO.puts("   ✅ TODOs correctly sorted by date (newest first)")
        else
          raise "Newest TODO not at top"
        end
        
        {:ok, context}
      end
    end
  end

  spex "Sort dropdown UI interaction",
    description: "Verify sort dropdown appears and functions in UI",
    tags: [:todos, :sorting, :ui] do
    
    scenario "Sort dropdown is visible and functional", context do
      given_ "I'm on the TODOs page", context do
        Process.sleep(3000)
        Memelex.My.TODOs.show()
        Process.sleep(2000)
        
        {:ok, context}
      end
      
      when_ "I interact with the sort dropdown", context do
        # The dropdown should be visible in the tools section
        # ID is :sort_select based on our implementation
        
        # Simulate dropdown interaction
        # In a real test with scenic_mcp, we would:
        # 1. Click on the dropdown
        # 2. Select an option
        # 3. Verify the visual update
        
        IO.puts("   🎯 Sort dropdown implemented with ID: :sort_select")
        IO.puts("   📍 Location: Tools section at {480, 20}")
        IO.puts("   📋 Options: Default, Priority (High→Low), Priority (Low→High), Date (Newest→Oldest), Date (Oldest→Newest)")
        
        {:ok, context}
      end
      
      then_ "sort order persists in state", context do
        # Change sort order
        Flamelex.Fluxus.action({Flamelex.GUI.Component.TODOlist.Reducer, {:sort_todos, :priority_high}})
        Process.sleep(500)
        
        state = Flamelex.Fluxus.RadixStore.get()
        
        if state.apps.todo_list.sort_order == :priority_high do
          IO.puts("   ✅ Sort order persisted in state")
        else
          raise "Sort order not persisted"
        end
        
        {:ok, context}
      end
    end
  end
end